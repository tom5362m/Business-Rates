#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

#load in dependencies
library(shiny)
library(tidyverse)
library(knitr)
library(readxl)# For importing from excel spreadsheets
library(visNetwork)#networking interactive graph package
library(lubridate)
library(markdown)
library(knitr)

# Define UI for application that draws a histogram


ui <- shinyUI(
  fluidPage(
    includeHTML('C:/Users/thoma/OneDrive/Documents/Goodman Nash/Business-Rates/Interactive graph.html')
  )
)
server <- function(input, output) {
}

shinyApp(ui, server)

shinyApp(ui, server)