shinyUI(
  fluidPage(
    titlePanel('JIRA Project Analysis'),
    sidebarLayout(
      sidebarPanel(
        fileInput('issuesFile', 'Issues CSV File', FALSE, c('text/csv')),
        conditionalPanel(
          condition = "output.issuesSet",
          selectInput('column', 'Column', c())
        )
      ),
      mainPanel(tableOutput('table'))
    )
  )
)
