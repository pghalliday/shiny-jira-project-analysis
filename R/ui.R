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
        selectInput('dayVariable', 'Variable', c(
          'open',
          'technicalDebt',
          'leadTime',
          'cycleTime',
          'deferredTime'
        )),
        selectInput('dayPartition', 'Partition', c(
          'type',
          'priority',
          'component'
        )),
        conditionalPanel(
          condition = "input.dayPartition === 'type'",
          checkboxGroupInput('dayTypes', 'Types', c('none'))
        ),
        conditionalPanel(
          condition = "input.dayPartition === 'priority'",
          checkboxGroupInput('dayPriorities', 'Priorities', c('none'))
        ),
        conditionalPanel(
          condition = "input.dayPartition === 'component'",
          checkboxGroupInput('dayComponents', 'Components', c('none'))
        )
      )
    ),
    mainPanel(
      conditionalPanel(
        condition = "input.dayVariable === 'open'",
        conditionalPanel(
          condition = "input.dayPartition === 'type'",
          plotOutput('daysOpenByType')
        ),
        conditionalPanel(
          condition = "input.dayPartition === 'priority'",
          plotOutput('daysOpenByPriority')
        ),
        conditionalPanel(
          condition = "input.dayPartition === 'component'",
          plotOutput('daysOpenByComponent')
        )
      ),
      conditionalPanel(
        condition = "input.dayVariable === 'technicalDebt'",
        conditionalPanel(
          condition = "input.dayPartition === 'type'",
          plotOutput('daysTechnicalDebtByType')
        ),
        conditionalPanel(
          condition = "input.dayPartition === 'priority'",
          plotOutput('daysTechnicalDebtByPriority')
        ),
        conditionalPanel(
          condition = "input.dayPartition === 'component'",
          plotOutput('daysTechnicalDebtByComponent')
        )
      ),
      conditionalPanel(
        condition = "input.dayVariable === 'leadTime'",
        conditionalPanel(
          condition = "input.dayPartition === 'type'",
          plotOutput('daysLeadTimeByType')
        ),
        conditionalPanel(
          condition = "input.dayPartition === 'priority'",
          plotOutput('daysLeadTimeByPriority')
        ),
        conditionalPanel(
          condition = "input.dayPartition === 'component'",
          plotOutput('daysLeadTimeByComponent')
        )
      ),
      conditionalPanel(
        condition = "input.dayVariable === 'cycleTime'",
        conditionalPanel(
          condition = "input.dayPartition === 'type'",
          plotOutput('daysCycleTimeByType')
        ),
        conditionalPanel(
          condition = "input.dayPartition === 'priority'",
          plotOutput('daysCycleTimeByPriority')
        ),
        conditionalPanel(
          condition = "input.dayPartition === 'component'",
          plotOutput('daysCycleTimeByComponent')
        )
      ),
      conditionalPanel(
        condition = "input.dayVariable === 'deferredTime'",
        conditionalPanel(
          condition = "input.dayPartition === 'type'",
          plotOutput('daysDeferredTimeByType')
        ),
        conditionalPanel(
          condition = "input.dayPartition === 'priority'",
          plotOutput('daysDeferredTimeByPriority')
        ),
        conditionalPanel(
          condition = "input.dayPartition === 'component'",
          plotOutput('daysDeferredTimeByComponent')
        )
      )
    )
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
