source('config.R')

commitData <- {
  repo = git2r::repository(datadir)
  commits = git2r::commits(repo)
  commit = commits[[1]]
  author = commit@author
  when = author@when
  paste(
    paste('date:', as.POSIXct(when@time, origin="1970-01-01")),
    paste('sha:', commit@sha),
    paste('name:', author@name),
    paste('email:', author@email),
    paste('message:', commit@message),
    sep = '\n'
  )
}

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
    pre(commitData),
    tabsetPanel(
      daysPanel,
      issuesPanel,
      id = 'tabs',
      type = 'tabs'
    )
  )
)
