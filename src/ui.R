issuesPanel <- tabPanel(
  'Issues',
  br(),
  sidebarLayout(
    sidebarPanel(
      fileInput('issuesFile', 'Issues CSV File', FALSE, c('text/csv')),
      htmlOutput('issueOptions')
    ),
    mainPanel(
      htmlOutput('issuePlots')
    )
  ),
  htmlOutput('issuesTablePanel'),
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
