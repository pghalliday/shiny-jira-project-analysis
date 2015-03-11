source('config.R')

source('days.R')
source('issues.R')

shinyServer(function(input, output, clientData, session) {
  days(datadir, input, output, clientData, session)
  issues(datadir, input, output, clientData, session)
})
