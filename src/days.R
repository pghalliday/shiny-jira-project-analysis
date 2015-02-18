days <- function(input, output, clientData, session) {
  daysReactive <- reactive({
    file <- input$daysFile
    if (!is.null(file)) {
      zoo::read.zoo(file[1, 'datapath'], sep = ',', header = TRUE, format = '%Y/%m/%d')
    }
  })

  dimensionsReactive <- reactive({
    days = daysReactive()
    if (!is.null(days)) {
      columns = colnames(days)
      matches = na.omit(
        stringr::str_match(
          columns,
          paste0("^([^.]*)\\.(.*)\\.([^.]*)$")
        )
      )
      variables = unique(matches[, 4])
      partitionNames = unique(matches[, 2])
      partitions = list()
      for (partition in partitionNames) {
        partitions[[partition]] = unique(matches[which(matches[, 2] == partition), 3])
      }
      list(
        variables = variables,
        partitions = partitions
      )
    }
  })

  generatePartitionOptions <- function (index, names, partitions) {
    partition <- names[index]
    options <- c('<all>', partitions[[index]])
    conditionalPanel(
      condition = paste0("input.dayPartition === '", partition, "'"),
      checkboxGroupInput(
        paste0('day_', partition, '_options'),
        paste0(partition, ' values'),
        options,
        options
      )
    )
  }

  generateAllPartitionOptions <- function (partitions) {
    Reduce(paste, lapply(
      seq_along(partitions),
      generatePartitionOptions,
      names = names(partitions),
      partitions = partitions
    ))
  }

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
    daysReactive()[, columns, drop = FALSE]
  }

  renderVariableByPartitionPlot <- function (variable, partition) {
    output[[paste0('days_', variable, '_by_', partition)]] <- renderPlot({
      data <- daysVariableByPartition(variable, partition)
      filteredData <- data[, colSums(is.na(data)) < nrow(data)]
      ylim = c(
        min(c(0, min(na.omit(filteredData)))),
        max(na.omit(filteredData))
      )
      (
        zoo::autoplot.zoo(data, facets = NULL, ylim = ylim)
        + geom_line(size = 1.5)
        + theme(text = element_text(size = 16))
      )
    })
  }

  generatePartitionPlot <- function (partition, variable) {
    renderVariableByPartitionPlot(variable, partition)
    conditionalPanel(
      condition = paste0("input.dayPartition === '", partition, "'"),
      plotOutput(paste0('days_', variable, '_by_', partition))
    )
  }

  generateVariablePlots <- function (variable, partitions) {
    do.call(
      conditionalPanel,
      c(
        condition = paste0("input.dayVariable === '", variable, "'"),
        lapply(
          names(partitions),
          generatePartitionPlot,
          variable = variable
        )
      )
    )
  }

  generatePlots <- function (variables, partitions) {
    Reduce(paste, lapply(
      variables,
      generateVariablePlots,
      partitions = partitions
    ), '')
  }

  observe({
    dimensions = dimensionsReactive()
    if (!is.null(dimensions)) {
      variables = dimensions$variables
      partitions = dimensions$partitions
      output$dayOptions <- renderUI({
        HTML(
          paste(
            selectInput('dayVariable', 'Variable', variables),
            selectInput('dayPartition', 'Partition', names(partitions)),
            generateAllPartitionOptions(partitions),
            checkboxInput('showDaysTable', 'Show data table')
          )
        )
      })
      output$dayPlots <- renderUI({
        html <- ''
        html <- paste(
          html, 
          generatePlots(variables, partitions)
        )
        HTML(html)
      })
      output$daysTablePanel <- renderUI({
        html <- ''
        html <- paste(
          html, 
          conditionalPanel(
            condition = 'input.showDaysTable',
            tableOutput('daysTable')
          )
        )
        HTML(html)
      })
      output$daysTable <- renderTable({
        daysReactive()
      })
    }
  })
}
