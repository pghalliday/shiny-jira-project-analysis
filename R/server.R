shinyServer(function(input, output, clientData, session) {
  issuesSet <- reactive({
    !is.null(input$issuesFile)
  })
  daysSet <- reactive({
    !is.null(input$daysFile)
  })

  issues <- reactive({
    if (issuesSet()) {
      read.csv(
        input$issuesFile[1, 'datapath'],
        header = TRUE
      )
    }
  })

  days <- reactive({
    if (daysSet()) {
      zoo::read.zoo(input$daysFile[1, 'datapath'], sep = ',', header = TRUE, format = '%Y/%m/%d')
    }
  })

  output$issuesSet <- issuesSet
  outputOptions(output, 'issuesSet', suspendWhenHidden = FALSE)
  
  output$daysSet <- daysSet
  outputOptions(output, 'daysSet', suspendWhenHidden = FALSE)
  
  output$issuesTable <- renderTable({
    issues()
  })

  output$daysTable <- renderTable({
    days()
  })

  mapToColumn <- function (value, prefix, suffix) {
    if (identical('<all>', value)) {
      result <- suffix
    } else {
      result <- paste(prefix, value, suffix, sep = '.') 
    }
    return(result)
  }

  daysVariableByPartition <- function (variable, partition) {
    day_partition_options <- input[[paste0('day_', partition, '_options')]]
    columns <- sapply(day_partition_options, mapToColumn, prefix = partition, suffix = variable)
    days()[, columns, drop = FALSE]
  }

  renderDayVariableByPartitionPlot <- function (variable, partition) {
    output[[paste0('days_', variable, '_by_', partition)]] <- renderPlot({
      data <- daysVariableByPartition(variable, partition)
      colors = rainbow(ncol(data))
      columns = colnames(data)
      plot(data,
        plot.type = 'single',
        col = colors,
        lwd = 2,
        ylim = c(
          min(c(0, min(na.omit(data)))),
          max(na.omit(data))
        )
      )
      legend(
        'topleft',
        legend = columns,
        col = colors,
        lwd = 2
      )
    })
  }

  renderDayVariablePlots <- function (variable) {
    sapply(dayPartitions, renderDayVariableByPartitionPlot, variable = variable)
  }

  sapply(dayVariables, renderDayVariablePlots)

  updatePartitionOptions <- function (columns, partition) {
    options <- c(
      '<all>',
      unique(
        na.omit(
          stringr::str_match(
            columns,
            paste0("^", partition, "\\.(.*)\\.[^.]*$")
          )[,2]
        )
      )
    )
    updateCheckboxGroupInput(
      session,
      paste0('day_', partition, '_options'),
      choices = options,
      selected = options
    )
  }

  observe({
    if (issuesSet()) {
      columns <- colnames(issues())
      updateSelectInput(
        session,
        'issueFields',
        choices = c('<NONE>', columns)
      )
    }
    if (daysSet()) {
      columns <- colnames(days())
      sapply(dayPartitions, updatePartitionOptions, columns = columns)
    }
  })
})
