days <- function(datadir, input, output, clientData, session) {
  days <- zoo::read.zoo(file.path(datadir, 'jira-days.csv'), sep = ',', header = TRUE, format = '%Y/%m/%d')

  dimensions <- {
    columns = colnames(days)
    matches = na.omit(
      stringr::str_match(
        columns,
        "^([^.]*)\\.(.*)\\.([^.]*)$"
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

  generateVariableOptions <- function (variable) {
    conditionalPanel(
      condition = paste0("input.dayVariable === '", variable, "'"),
      sliderInput(
        paste0('day_', variable, '_ma'),
        'Moving Average Window',
        min = 1,
        max = 30,
        value = 1
      )
    )
  }

  generateAllVariableOptions <- function (variables) {
    lapply(
      variables,
      generateVariableOptions
    )
  }

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
    lapply(
      seq_along(partitions),
      generatePartitionOptions,
      names = names(partitions),
      partitions = partitions
    )
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
    days[, columns, drop = FALSE]
  }

  renderVariableByPartitionPlot <- function (variable, partition) {
    output[[paste0('days_', variable, '_by_', partition)]] <- renderPlot({
      range = input$dayRange
      data <- daysVariableByPartition(variable, partition)[range[1]:range[2], ]
      dataMA <- zoo::rollapply(data, input[[paste0('day_', variable, '_ma')]], mean)
      filteredData <- dataMA[, colSums(is.na(dataMA)) < nrow(dataMA)]
      ylim = c(
        min(c(0, min(na.omit(filteredData)))),
        max(na.omit(filteredData))
      )
      (
        zoo::autoplot.zoo(dataMA, facets = NULL, ylim = ylim)
        + geom_line(size = 1.5)
        + theme(text = element_text(size = 16))
      )
    })
  }

  generatePartitionPlot <- function (partition, variable) {
    renderVariableByPartitionPlot(variable, partition)
    conditionalPanel(
      condition = paste0("input.dayPartition === '", partition, "'"),
      plotOutput(paste0('days_', variable, '_by_', partition), height = input$dayPlotHeight)
    )
  }

  generateVariablePlots <- function (variable, partitions) {
    do.call(
      conditionalPanel,
      list(
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
    lapply(
      variables,
      generateVariablePlots,
      partitions = partitions
    )
  }

  variables = dimensions$variables
  partitions = dimensions$partitions
  output$dayOptions <- renderUI({
    do.call(
      verticalLayout,
      list(
        sliderInput('dayPlotHeight', 'Plot Height', min = 100, max = 2000, value = 700),
        sliderInput(
          'dayRange',
          'Range',
          min = 1,
          max = nrow(days),
          value = c(1, nrow(days))
        ),
        selectInput('dayVariable', 'Variable', variables),
        generateAllVariableOptions(variables),
        selectInput('dayPartition', 'Partition', names(partitions)),
        generateAllPartitionOptions(partitions),
        checkboxInput('showDaysTable', 'Show data table')
      )
    )
  })
  output$dayPlots <- renderUI({
    generatePlots(variables, partitions)
  })
  output$daysTablePanel <- renderUI({
    conditionalPanel(
      condition = 'input.showDaysTable',
      tableOutput('daysTable')
    )
  })
  output$daysTable <- renderTable({
    days
  })
}
