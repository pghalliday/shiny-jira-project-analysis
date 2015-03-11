issues <- function(datadir, input, output, clientData, session) {

  measures <- c(
    'leadTime',
    'cycleTime',
    'deferredTime'
  )

  issues <- {
    issues = read.csv(file.path(datadir, 'jira-issues.csv'))
    issues$created <- as.Date(issues$created, '%Y/%m/%d')
    issues$closed <- as.Date(issues$closed, '%Y/%m/%d')
    issues
  }

  closedIssues <- issues[!(is.na(issues$closed)), ]
  minClosedDate <- min(closedIssues$closed)
  maxClosedDate <- max(closedIssues$closed)
  filteredClosedIssuesReactive <- reactive({
    closedIssues[closedIssues$closed >= (maxClosedDate - input$issueDays), ]
  })

  dimensions <- {
    columns = colnames(issues)
    labelMatches = na.omit(
      stringr::str_match(
        columns,
       '^label\\.(.*)$'
      )
    )
    labels = unique(labelMatches[, 1])
    componentMatches = na.omit(
      stringr::str_match(
        columns,
       '^component\\.(.*)$'
      )
    )
    components = unique(componentMatches[, 1])
    list(
      labels = labels,
      components = components
    )
  }

  densityPlot <- function (measure) {
    cropInputName = paste0('issue_density_', measure, '_crop')
    binInputName = paste0('issue_density_', measure, '_bin')
    crop = input[[cropInputName]]
    bin = input[[binInputName]]
    closedIssues = filteredClosedIssuesReactive()
    closedIssues = closedIssues[closedIssues[[measure]] >= crop[1] & closedIssues[[measure]] <= crop[2], ]
    minMeasure <- floor(min(closedIssues[[measure]]))
    maxMeasure <- ceiling(max(closedIssues[[measure]]))
    (
      ggplot2::ggplot(
        closedIssues,
        ggplot2::aes_string(x = measure)
      )
      + ggplot2::geom_histogram(
        ggplot2::aes(y = ..density..),
        binwidth = bin,
        colour = "black",
        fill = "white"
      )
      + ggplot2::geom_density(
        alpha = 0.2,
        fill = '#FF6666'
      )
      + ggplot2::geom_vline(
        xintercept = mean(closedIssues[[measure]]),
        color = 'red',
        linetype = 'dashed',
        size = 1
      )
      + ggplot2::geom_vline(
        xintercept = median(closedIssues[[measure]]),
        color = 'blue',
        linetype = 'dashed',
        size = 1
      )
      + ggplot2::scale_x_continuous(
        breaks = round(
          seq(minMeasure, maxMeasure, by = bin),
          minMeasure
        )
      )
    )
  }

  densityPlotPanel <- function (measure) {
    outputName = paste0('issue_density_', measure, '_plot')
    output[[outputName]] <- renderPlot({
      densityPlot(measure)
    })
    conditionalPanel(
      paste0('input.issueDensities === "', measure, '"'),
      plotOutput(outputName, height = input$issuePlotHeight)
    )
  }

  densityPlotPanels <- function () {
    lapply(measures, densityPlotPanel)
  }

  densityOptionPanel <- function (measure) {
    cropInputName = paste0('issue_density_', measure, '_crop')
    binInputName = paste0('issue_density_', measure, '_bin')
    defaultValue = c(
      floor(min(closedIssues[[measure]])),
      ceiling(max(closedIssues[[measure]]))
    )
    conditionalPanel(
      paste0('input.issueDensities === "', measure, '"'),
      sliderInput(cropInputName, 'Crop', defaultValue[1], defaultValue[2], defaultValue),
      sliderInput(binInputName, 'Bin Size', 1, defaultValue[2], 5)
    )
  }

  densityOptionPanels <- function () {
    lapply(measures, densityOptionPanel)
  }

  scatterMatrix <- function () {
    closedIssues <- filteredClosedIssuesReactive()
    leadTime <- closedIssues$leadTime
    leadTimeCrop <- input$issue_scatter_leadTime_crop
    cycleTime <- closedIssues$cycleTime
    cycleTimeCrop <- input$issue_scatter_cycleTime_crop
    deferredTime <- closedIssues$deferredTime
    deferredTimeCrop <- input$issue_scatter_deferredTime_crop
    closedIssues <- closedIssues[
      leadTime >= leadTimeCrop[1] &
      leadTime <= leadTimeCrop[2] &
      cycleTime >= cycleTimeCrop[1] &
      cycleTime <= cycleTimeCrop[2] &
      deferredTime >= deferredTimeCrop[1] &
      deferredTime <= deferredTimeCrop[2]
    , ]
    output$issueScatterMatrix <- renderPlot({
      GGally::ggpairs(closedIssues[ , c('leadTime', 'cycleTime', 'deferredTime')])
    })
    plotOutput('issueScatterMatrix', height = input$issuePlotHeight)
  }

  scatterOption <- function (measure) {
    cropInputName = paste0('issue_scatter_', measure, '_crop')
    defaultValue = c(
      floor(min(closedIssues[[measure]])),
      ceiling(max(closedIssues[[measure]]))
    )
    sliderInput(cropInputName, paste('Crop', measure), defaultValue[1], defaultValue[2], defaultValue)
  }

  scatterOptions <- function () {
    lapply(measures, scatterOption)
  }

  maxDays <- as.numeric(maxClosedDate - minClosedDate)
  output$issueOptions <- renderUI({
    verticalLayout(
      sliderInput('issuePlotHeight', 'Plot Height', min = 100, max = 2000, value = 700),
      sliderInput('issueDays', 'Days', min = 1, max = maxDays, value = maxDays),
      selectInput('issuePlots', 'Plot', c('density', 'scatter')),
      conditionalPanel(
        'input.issuePlots === "density"',
        selectInput(
          'issueDensities',
          'Measure',
          measures
        ),
        densityOptionPanels()
      ),
      conditionalPanel(
        'input.issuePlots === "scatter"',
        scatterOptions()
      ),
      checkboxInput('showIssuesTable', 'Show data table')
    )
  })
  output$issuePlots <- renderUI({
    verticalLayout(
      conditionalPanel(
        'input.issuePlots === "density"',
        densityPlotPanels()
      ),
      conditionalPanel(
        'input.issuePlots === "scatter"',
        scatterMatrix()
      )
    )
  })
  output$issuesTablePanel <- renderUI({
    conditionalPanel(
      condition = 'input.showIssuesTable',
      tableOutput('issuesTable')
    )
  })
  output$issuesTable <- renderTable({
    issues
  })
}
