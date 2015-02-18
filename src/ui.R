issuesPanel <- tabPanel(
  'Issues',
  br(),
  sidebarLayout(
    sidebarPanel(
      fileInput('issuesFile', 'Issues CSV File', FALSE, c('text/csv')),
      conditionalPanel(
        condition = "output.issuesSet",
        selectInput('issueFields', 'Issue Fields', c()),
        checkboxInput('showIssuesTable', 'Show data table')
      )
    ),
    mainPanel()
  ),
  conditionalPanel(
    condition = 'output.issuesSet && input.showIssuesTable',
    tableOutput('issuesTable')
  ),
  value = 'issues'
)

daysPanel <- tabPanel(
  'Days',
  br(),
  sidebarLayout(
    sidebarPanel(
      fileInput('daysFile', 'Days CSV File', FALSE, c('text/csv')),
      htmlOutput('dayOptions')
    ),
    mainPanel(
      htmlOutput('dayPlots')
    )
  ),
  htmlOutput('daysTablePanel'),
  value = 'days'
)

shinyUI(
  fluidPage(
    titlePanel('JIRA Project Analysis'),
    tabsetPanel(
      daysPanel,
      issuesPanel,
      id = 'tabs',
      type = 'tabs'
    )
  )
)
