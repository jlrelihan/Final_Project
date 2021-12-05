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
library(ggimage)



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
    unique_teams <- select(super_bowl, home_vs_away, home_score, away_score, game_year, qtr, game_seconds_remaining, home_team, away_team, interception, penalty,sack,touchdown,fumble )
    
    # Filter data set for final score
    unique_teams <- filter(unique_teams, qtr==4, game_seconds_remaining==0)
    
    # New column shows which team home or away won the game
    unique_teams <- mutate(unique_teams,winner= ifelse(unique_teams$home_score>unique_teams$away_score, "home","away"))
    
    # New column shows which team won the game
    unique_teams <- mutate(unique_teams,team_looser = ifelse(unique_teams$winner=="home",unique_teams$away_team,unique_teams$home_team))
    
    # New column shows which team lost the game
    unique_teams <- mutate(unique_teams,team_winner = ifelse(unique_teams$winner=="home",unique_teams$home_team,unique_teams$away_team))
    
    # Select only interested columns
    unique_teams <- select(unique_teams, home_vs_away, home_score, away_score, team_winner ,team_looser,game_year)

    # List of match ups in the last 21 years of the Superbowl
    output$teams <- renderDataTable({
        unique_teams
            })

    # Bar plot showing the winning teams that played in the last 21 years of the Superbowl.
    output$bar_1 <- renderPlot({
        if(input$win_loose == "Winner"){
        g <- ggplot(unique_teams, aes(x= forcats::fct_infreq(team_winner)))
        g + geom_bar(aes(fill=team_winner)) + labs(title = "Total Wins by Team", x= "Team")
        }
        else if(input$win_loose == "Loser"){
            g <- ggplot(unique_teams, aes(x= forcats::fct_infreq(team_looser)))
            g + geom_bar(aes(fill=team_looser)) + labs(title = "Total Loses by Team", x= "Team")
        }
    })
        
    
    # Bar plot 2 to visualize: 
    # "interception","penalty","sack","touchdown","fumble","passing_yards"
    output$bar_2 <- renderPlot({
        if(input$y_axis == "touchdown"){
            g <- ggplot(super_bowl, aes(x= game_id))
            g + geom_col(aes(y=touchdown, fill=td_team)) + labs(title="Total Touchdowns per Game",y="Touchdowns",x="Game ID")+ theme(axis.text.x=element_text(angle=90))
        }
        else if(input$y_axis == "interception"){
            g <- ggplot(super_bowl, aes(x= game_id))
            g + geom_col(aes(y=interception)) + labs(title="Total Interceptions per Game",y="Interceptions",x="Game ID")+ theme(axis.text.x=element_text(angle=90))
        }
        else if(input$y_axis == "penalty"){
            g <- ggplot(super_bowl, aes(x= game_id))
            g + geom_col(aes(y=penalty)) + labs(title="Total Penalties per Game",y="Penalties",x="Game ID")+ theme(axis.text.x=element_text(angle=90))
        }
        else if(input$y_axis == "sack"){
            g <- ggplot(super_bowl, aes(x= game_id))
            g + geom_col(aes(y=sack)) + labs(title="Total Sacks per Game",y="Sacks",x="Game ID")+ theme(axis.text.x=element_text(angle=90))
        }
        else if(input$y_axis == "fumble"){
            g <- ggplot(super_bowl, aes(x= game_id))
            g + geom_col(aes(y=fumble)) + labs(title="Total Fumbles per Game",y="Fumbles",x="Game ID")+ theme(axis.text.x=element_text(angle=90))
        }
    }
    )
    
    # Data Prep for Table for team roster by game year
    roster <- nflfastR::fast_scraper_roster(1999:2021)
    # Join roster to super bowl data
    joined <- super_bowl %>%
        filter(!is.na(receiver_id)) %>%
        select(posteam, season, desc, receiver, receiver_id, epa) %>%
        left_join(roster, by = c("receiver_id" = "gsis_id")) %>%
        group_by(receiver_id, position, season.y, team,full_name) %>%
        summarize(Total_EPA = sum(epa)) %>%
        select(team, full_name, position,season.y,receiver_id,Total_EPA)  %>%
        rename(Team=team, Name=full_name, Season=season.y, Position=position, Receiver.ID = receiver_id)
    
        # Reactive data set for Roster
        datasetInput2 <- reactive(
            if(input$team == "All" & input$position == "All" & input$year == "All") {
                newData2 <- joined
                newData2
            }
            else if(input$team != "All" & input$position == "All" & input$year == "All") {
                newData2 <- joined %>% filter(Team == input$team)
                newData2
            }
            else if(input$team == "All" & input$position != "All" & input$year == "All") {
                newData2 <- joined %>% filter(Position == input$position)
                newData2
            }
            else if(input$team != "All" & input$position != "All" & input$year == "All") {
                newData2 <- joined %>% filter(Team == input$team) %>% filter(Position == input$position)
                newData2
            }
            else if(input$team == "All" & input$position == "All" & input$year != "All") {
                newData2 <- joined %>% filter(Season == input$year)
                newData2
            }
            else if(input$team != "All" & input$position == "All" & input$year != "All") {
                newData2 <- joined %>% filter(Team == input$team) %>% filter(Season == input$year)
                newData2
            }
            else if(input$team == "All" & input$position != "All" & input$year != "All") {
                newData2 <- joined %>% filter(Position == input$position) %>% filter(Season == input$year)
                newData2
            }
            else if(input$team != "All" & input$position != "All" & input$year != "All") {
                newData2 <- joined %>% filter(Team == input$team) %>% filter(Position == input$position) %>% filter(Season == input$year)
                newData2
            }
        )
        
    # Season Roster Table
    output$mytable2 <- renderDataTable({
        datasetInput2()
    })

    
    })