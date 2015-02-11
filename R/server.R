shinyServer(function(input, output, clientData, session) {
  issuesSet <- reactive({
    !is.null(input$issuesFile)
  })

  issues <- reactive({
    if (issuesSet()) {
      read.csv(
        input$issuesFile[1, 'datapath'],
        header = TRUE
      )
    }
  })

  output$issuesSet <- issuesSet
  outputOptions(output, 'issuesSet', suspendWhenHidden = FALSE)
  
  output$table <- renderTable({
    issues()
  })

  observe({
    if (issuesSet()) {
      columns = colnames(issues())
      updateSelectInput(
        session,
        'column',
        choices = c('<NONE>', columns)
      )
    }
  })
})
