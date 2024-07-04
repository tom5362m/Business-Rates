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


ui <- fluidPage(
  theme = bs_theme(
    base_font = c("Arial"),
    primary = c("#e30513")
  ),
  sidebarLayout(
    sidebarPanel(
      textOutput("panel"),
      h2("Property reconstitution"),
      selectizeInput("dataset",
                     multiple = TRUE),
      markdown("
               A shiny app to visualise the history of a property and how it has been split or merged together.
               
               It will identify splits/merges/address changes and show which of these is relevant.
               
               Lastly it will give an indication of whether SBRR could be applied to that heredit indvidually- does not check for multistes just if the RV could be due SBRR
               
               My code an be found in the code tab
               ")
      ),
    mainPanel(
      tabsetPanel(
        id="tabset",
        tabsetPanel("Network")
      )
    )
  )
)


shinyApp(ui, server)

shinyApp(ui, server)