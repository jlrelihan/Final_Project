library(shiny)
library(httr)
library(jsonlite)
library(base)
library(tidyverse)
library(dplyr)
library(magrittr)
library(ggplot2)
library(bslib)
library(DT)

# Shiny App
shinyUI(fluidPage(
    
    # Adding theme
    theme = bs_theme(bootswatch = "sandstone"),
    
    # Application title
    titlePanel("NFL Super Bowl Data Explorer"),
    
    # Set up Navigation Bar
    navbarPage("NFL Data Explorer",
               tabPanel("About",
                        img(src="nfllogo.png",align="center",height=200,width=400),
                        h2(strong("Purpose of App:")),
                        h5("This app lets you explore NFL Superbowl Data over the past 20 years"),
                        h2(strong("Data Review:")),
                        h5("The data used for this app is from the nflfastR package. The package contains NFL play-by-play data where you can access different game types including super bowl and regular season data. You can also access many years of data back to 1999. For more information: ", a(href = "https://www.nflfastr.com/","Click here")),
                        h2(strong("Tab Overview:")),
                        h4("Data Exploration"),
                            h5("On this page you can view numerical and graphical summaries of the data."),
                        h4("Modeling"),
                            h5("In each tab of this page you can view the three different supervised learning models."),
                        h4("Modeling Info"),
                            h5("On this page there are details explaining each of the three modeling approaches and their benefits and drawbacks."),
                        h4("Model Fitting"),
                            h5("On this page you can fit the models. You'll be able to choose some of the modeling parameters like the proportion of data used in each training and test set and variables used."),
                        h4("Prediction"),
                            h5("On this page you can choose one of the models for prediction."),
                        h4("Data"),
                            h5("Here you can scroll through the full data set, subset the data for specific columns and game years, and download the file as a csv.")
               ),
               tabPanel("Data Exploration",
                        # Numerical & Graphical Summaries
                        sidebarLayout(
                            sidebarPanel(
                                
                            ),
                            mainPanel(
                                h2("Final Scores for the last 21 years of the Superbowl"),
                                DT::dataTableOutput("teams"),
                                plotOutput("bar_1"),
                                plotOutput("bar_2")
                            )
                        )
               ),
               navbarMenu("Modeling",
                          tabPanel("Model 1"),
                          tabPanel("Model 2"),
                          tabPanel("Model 3")
               ),
               tabPanel("Modeling Info",
                        # Explanation, benefits, drawbacks, math type 
               ),
               tabPanel("Model Fitting",
                        
               ),
               tabPanel("Prediction",
                        
               ),
               tabPanel("Data",
                        sidebarLayout(
                            sidebarPanel(
                                selectInput("yearx", label = "Game Year", 
                                            choices = c("All","2000","2001","2002","2003","2004","2005","2006","2007","2008","2009","2010","2011","2012","2013","2014","2015","2016","2017","2018","2019","2020"), selected = "All"),
                                h6("Show Filters"),
                                checkboxInput("show_filters",label=NULL,value=FALSE),
                                conditionalPanel("input.show_filters",
                                                 checkboxGroupInput(
                                                     'show_vars','Columns in data to show',
                                                     c("home_team", "away_team", "season_type", "game_date","game_year","play_type","home_vs_away"),selected=c("home_team", "away_team", "season_type", "game_date","game_year","play_type","home_vs_away")
                                                 )),
                                downloadButton("downloaddata","Download Data")
                            ),
                            mainPanel(
                                h2("Super Bowl Data"),
                                DT::dataTableOutput("mytable"),
                            )
                        )
               )
    )
))