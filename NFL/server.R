library(shiny)
library(magrittr)
library(nflfastR)
library(gsisdecoder)
library(future)
plan(multisession)
library(dplyr)
library(tidyr)
library(DT)
library(ggplot2)



shinyServer(function(input, output) {
    # Bring in data set
    super <- nflfastR::fast_scraper_schedules(1999:2020) %>%
        dplyr::filter(game_type == "SB") %>%
        dplyr::pull(game_id)
    
    super_bowl <- nflfastR::build_nflfastR_pbp(super)
    
    # Create a cleaned up date column for just the year.
    super_bowl <- super_bowl %>% separate(game_date, into = c("game_year"), sep = "-", remove = FALSE)
    # Create a new column for team vs team (home team vs away team)
    super_bowl <- super_bowl %>% mutate(home_vs_away= paste(super_bowl$home_team,"vs ", super_bowl$away_team))
    
    # Creating a reactive data object - this is used for data page for the data table filters.
    datasetInput <- reactive(
        if(input$show_filters == FALSE & input$yearx == "All") {
            newData <- super_bowl
            newData
        }
        else if(input$show_filters == FALSE & input$yearx != "All") {
            newData <- super_bowl %>% filter(game_year == input$yearx)
            newData
        }
        else if(input$show_filters == TRUE & input$yearx == "All"){
            newData <- super_bowl
            newData[,input$show_vars]
        }
        else if(input$show_filters == TRUE & input$yearx != "All"){
            newData <- super_bowl %>% filter(game_year == input$yearx)
            newData[,input$show_vars]
        }
    )
    
    # Data table to scroll through
    output$mytable <- DT::renderDataTable({
        datasetInput()
    })
    # Download data button
    output$downloaddata <- downloadHandler(
        filename = "data",
        content = function(file) {
            write.csv(datasetInput(), file, row.names = FALSE)
        }
    )
    
    # Data Exploration Page
    
    # Getting a table of unique teams and game years
    unique_teams <- select(super_bowl, home_vs_away, home_score, away_score, game_year, qtr, game_seconds_remaining, home_team, away_team )
    # Filter dataset for final score
    unique_teams <- filter(unique_teams, qtr==4, game_seconds_remaining==0)
    # New column shows which team home or away won the game
    unique_teams <- mutate(unique_teams,winner= ifelse(unique_teams$home_score>unique_teams$away_score, "home","away"))
    # New column shows which team won the game
    unique_teams <- mutate(unique_teams,team_winner = ifelse(unique_teams$winner=="home",unique_teams$home_team,unique_teams$away_team))
    
    # Select only interested columns
    unique_teams <- select(unique_teams, home_vs_away, home_score, away_score, team_winner ,game_year)
    
    # List of unique teams that played in the last 21 years of the Superbowl
    output$teams <- renderDataTable({
        unique_teams
            })

    # Bar plot showing the winning teams that played in the last 21 years of the Superbowl.
    output$bar_1 <- renderPlot({
        g <- ggplot(unique_teams, aes(x=team_winner))
        g + geom_bar()
    }
        
    )
    
    })



