source('days.R')

shinyServer(function(input, output, clientData, session) {

  days(input, output, clientData, session)

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
  
  output$issuesTable <- renderTable({
    issues()
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
  })
})
