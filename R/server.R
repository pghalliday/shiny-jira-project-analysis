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

  daysOpenByType <- reactive({
    types <- input$dayTypes
    columns <- sapply(types, mapToColumn, prefix = 'type', suffix = 'open')
    days()[, columns]
  })

  output$daysOpenByType <- renderPlot({
    data <- daysOpenByType()
    colors = rainbow(ncol(data))
    columns = colnames(data)
    plot(data, plot.type = 'single', col = colors, lwd = 2)
    legend('topleft', legend = columns, col = colors, lwd = 2)
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
