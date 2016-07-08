library(shiny)
library(ggplot2)
library(ggthemes)
source("functions.R", local = TRUE)

playerData <- getPlayerData()

shinyServer(
     
     function(input, output) {
          
          plot <- renderPlot({neatGraphs(playerData, {input$players}, {input$stat})})
          
          output$plot <- plot
          
     }
)
