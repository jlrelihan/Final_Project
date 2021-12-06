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
                            h5("On this page you can view numerical and graphical summaries of the data. You can view total wins and loses by team. For each Superbowl game you can select different variables like touchdowns, sacks, interceptions, penalties, and fumbles. You can also see the roster across seasons where you can see the total EPA per player and filter by team, position, and game year. Last, you can see the final scores for the last 20 years of the Superbowl."),
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
                                selectInput("win_loose", label = "Game Outcome", 
                                            choices = c("Winner","Loser"), selected = "Winner"),
                                br(),br(),br(),br(),br(),br(),br(),br(),br(),br(),br(),br(),br(),
                                selectInput("y_axis","Select Metric",choices = list("interception","penalty","sack","touchdown","fumble"),selected = "touchdown"),
                                br(),br(),br(),br(),br(),br(),br(),br(),br(),br(),br(),br(),br(),br(),br(),br(),br(),br(),
                            selectInput("team","Team", choices= list("All","ARI","ATL","BAL","BUF","CAR","CHI","CIN","CLE","DAL","DEN","DET","GB","HOU","IND","JAC","KC","LV","LAC","LAR","MIA","MIN","NE","NO","NYG","NYJ","PHI","PIT","SF","SEA","TB","TEN","WAS"), selected ="All"),
                            selectInput("position","Position", choices = list("All","C", "DB", "DE", "DL", "DT", "E", "FB", "FL", "G", "HB", "K", "LB", "MLB", "NG", "NT", "OG", "OL", "OLB", "OT", "P", "QB", "RB", "S", "SE", "T", "TB", "TE", "WB", "WR"), selected = "All"),
                            selectInput("year", label = "Game Year", 
                                        choices = c("All","2000","2001","2002","2003","2004","2005","2006","2007","2008","2009","2010","2011","2012","2013","2014","2015","2016","2017","2018","2019","2020"), selected = "All")
                            ),
                            mainPanel(
                                plotOutput("bar_1"),
                                plotOutput("bar_2"),
                                h2("Season Roster"),
                                DT::dataTableOutput("mytable2"),
                                h2("Final Scores for the last 21 years of the Superbowl"),
                                DT::dataTableOutput("teams")
                            )
               )),
               navbarMenu("Modeling",
                          tabPanel("Modeling Info",
                                   sidebarLayout(
                                       sidebarPanel(
                                           
                                       ),
                                       mainPanel(
                                           h2("Model Details:"),
                                           h5("Linear Regression Models: Supervised learning includes regression models, tree based methods, and k nearest neighbors. The basic linear regression model includes a response, a value of our explanatory variable for the ith observation, the y-intercept, and the slope. The model aims to show a linear approach for modeling the relationship between predictors and some response. The model is fit by minimizing the sum of squared residuals, which is equivalent to assuming normality on  errors and using maximum liklihood to estimate the beta's. In R, the basic linear model fits done with lm(). When utilizing lm() in R, statistical analysis can be found using anova() or summary()."),
                                           br(),
                                           h5("Classification Tree: "),
                                           br(),
                                           h5("Random Forest Model: Random Forest modeling falls under supervised learning. It builds an ensemble of decision trees which help to get a more accurate prediction. The RF model extends the idea of bagging, generally better than bagging. It creates multiple trees from bootstrap samples.  ")
                                       )
                                   )
                                   ),
                          tabPanel("Model Fitting",
                                   sidebarLayout(
                                       sidebarPanel(
                                          actionButton("run","Go"),
                                          br(),
                                           sliderInput("train","Training Set",min=0.1,max=0.9, value=0.7, step=0.1),
                                           sliderInput("test","Test Set",min=0.1,max=0.9, value=0.3, step=0.1),
                                           selectInput("target_var","Target Variable", choices = c("wp","touchdown","pass_touchdown","rush_touchdown","return_touchdown","field_goal_attempt"),selected = "wp"),
                                           h6("The response variables are: yards_after_catch + ydstogo + yards_gained"),
                                       ),
                                       mainPanel(
                                           textOutput("info"),
                                           h2("Linear Regression"),
                                           DT::dataTableOutput("mytable3"),
                                           h2("Classification Tree"),
                                           DT::dataTableOutput("mytable4"),
                                           h2("Random Forest Model"),
                                           DT::dataTableOutput("mytable5"),
                                           
                                       )
                                   )
                                   ),
                          tabPanel("Prediction",
                                   sidebarLayout(
                                       sidebarPanel(
                                           
                                       ),
                                       mainPanel(
                                           
                                       )
                                   )
                                   )
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
                                DT::dataTableOutput("mytable")
                            )
                        )
               )
    )
))