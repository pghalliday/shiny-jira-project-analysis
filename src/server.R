source('days.R')
source('issues.R')

shinyServer(function(input, output, clientData, session) {
  days(input, output, clientData, session)
  issues(input, output, clientData, session)
})
