issuesPanel <- tabPanel(
  'Issues',
  br(),
  sidebarLayout(
    sidebarPanel(
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
