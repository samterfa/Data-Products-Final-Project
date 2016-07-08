library(shiny)
source("functions.R", local = TRUE)

playerData <- getPlayerData()

shinyUI(
    
     pageWithSidebar(
     
          # Create application title.
          headerPanel("Red Wings Player Statistics 2015-2016 Season"),
          
          ## Create checkboxes of players.
          sidebarPanel(
               
               checkboxGroupInput('players', 'Select Player(s)', choices = orderNames(playerData))
               
          ),
          
          mainPanel(
               
               ## Plot player(s) statistic over the course of the whole season.
               plotOutput("plot"),
               
               ## Select statistic to plot.
               selectInput('stat', 'Select Statistic', choices = append(names(playerData)[9:17], names(playerData)[19:20]))
          )
          
          
     )
     
     
)