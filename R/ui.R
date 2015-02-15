issuesPanel <- tabPanel(
  'Issues',
  br(),
  sidebarLayout(
    sidebarPanel(
      fileInput('issuesFile', 'Issues CSV File', FALSE, c('text/csv')),
      conditionalPanel(
        condition = "output.issuesSet",
        selectInput('issueFields', 'Issue Fields', c())
      )
    ),
    mainPanel(tableOutput('issuesTable'))
  ),
  value = 'issues'
)

daysPanel <- tabPanel(
  'Days',
  br(),
  sidebarLayout(
    sidebarPanel(
      fileInput('daysFile', 'Days CSV File', FALSE, c('text/csv')),
      conditionalPanel(
        condition = "output.daysSet",
        selectInput('dayFields', 'Day Fields', c())
      )
    ),
    mainPanel(tableOutput('daysTable'))
  ),
  value = 'days'
)

shinyUI(
  fluidPage(
    titlePanel('JIRA Project Analysis'),
    tabsetPanel(
      issuesPanel,
      daysPanel,
      id = 'tabs',
      type = 'tabs'
    )
  )
)
