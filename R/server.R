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
      read.csv(
        input$daysFile[1, 'datapath'],
        header = TRUE
      )
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

  observe({
    if (issuesSet()) {
      columns = colnames(issues())
      updateSelectInput(
        session,
        'issueFields',
        choices = c('<NONE>', columns)
      )
    }
    if (daysSet()) {
      columns = colnames(days())
      updateSelectInput(
        session,
        'dayFields',
        choices = c('<NONE>', columns)
      )
    }
  })
})
