dayPartitionOptionsPanel <- function (partition) {
  conditionalPanel(
    condition = paste0("input.dayPartition === '", partition, "'"),
    checkboxGroupInput(paste0('day_', partition, '_options'), paste0(partition, ' values'), c('none'))
  )
}

dayPartitionPanel <- function (variable, partition) {
  conditionalPanel(
    condition = paste0("input.dayPartition === '", partition, "'"),
    plotOutput(paste0('days_', variable, '_by_', partition))
  )
}

dayVariablePanel <- function (variable) {
  conditionalPanel(
    condition = paste0("input.dayVariable === '", variable, "'"),
    do.call(verticalLayout, lapply(dayPartitions, dayPartitionPanel, variable = variable))
  )
}

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
        condition = 'output.daysSet',
        selectInput('dayVariable', 'Variable', dayVariables),
        selectInput('dayPartition', 'Partition', dayPartitions),
        do.call(verticalLayout, lapply(dayPartitions, dayPartitionOptionsPanel))
      )
    ),
    do.call(mainPanel, lapply(dayVariables, dayVariablePanel))
  ),
  conditionalPanel(
    condition = 'output.daysSet',
    tableOutput('daysTable')
  ),
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
