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
      data <- read.csv(
        input$daysFile[1, 'datapath'],
        header = TRUE
      )
      data$date <- as.Date(data$date, '%Y/%m/%d')
      return(data)
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
    data <- days()
    data$date <- format(data$date, '%Y/%m/%d')
    return(data)
  })

  mapToColumn <- function (value, prefix, suffix) {
    if (identical('<all>', value)) {
      result <- suffix
    } else {
      result <- paste(prefix, value, suffix, sep = '.') 
    }
    return(result)
  }

  output$daysOpenByType <- renderPlot({
    types <- input$dayTypes
    columns <- sapply(types, mapToColumn, prefix = 'type', suffix = 'open')
    data <- days()[,columns]
    #data.zoo <- with(data, zoo::zoo(columns, order.by = data$date))
    #data.ts <- as.ts(data.zoo)
    #plot(data.ts)
  })

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
      types <- c('<all>', na.omit(stringr::str_match(columns, "^type\\.(.*)\\.open$")[,2]))
      updateCheckboxGroupInput(
        session,
        'dayTypes',
        choices = types,
        selected = types
      )
      priorities <- c('<all>', na.omit(stringr::str_match(columns, "^priority\\.(.*)\\.open$")[,2]))
      updateCheckboxGroupInput(
        session,
        'dayPriorities',
        choices = priorities,
        selected = priorities
      )
      components <- c('<all>', na.omit(stringr::str_match(columns, "^component\\.(.*)\\.open$")[,2]))
      updateCheckboxGroupInput(
        session,
        'dayComponents',
        choices = components,
        selected = components
      )
    }
  })
})
