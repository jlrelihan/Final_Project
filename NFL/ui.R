library(shiny)
library(httr)
library(jsonlite)
library(base)
library(tidyverse)
library(dplyr)
library(magrittr)
library(ggplot2)
library(bslib)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
    
    # Adding theme
    theme = bs_theme(bootswatch = "sandstone"),
    
    # Application title
    titlePanel("NFL Data Exploration"),
    
    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
            selectInput("yearx", label = "Game Year", 
                        choices = c("All","2000","2001","2002","2003","2004","2005","2006","2007","2008","2009","2010","2011","2012","2013","2014","2015","2016","2017","2018","2019","2020"),
                        selected = "All")
        ),
        # Show a plot of the generated distribution
        mainPanel(
            navbarPage("NFL Data Exploration",
                       tabPanel("About",
                                h3("Purpose of App:"),
                                textOutput("purpose"),
                                
                                h3("Data Review:"),
                                textOutput(""),
                                
                                h3("Tab Overview:"),
                                textOutput("")
                                # Add photo
                       ),
                       tabPanel("Data Exploration",
                                # Numerical & Graphical Summaries
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
                                #Scroll through data set
                                #Subset data set (rows and columns)
                                #Save subsetted data as a file (.csv)
                       )
            ))
    )
))