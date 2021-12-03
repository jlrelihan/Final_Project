library(shiny)
library(magrittr)
library(nflfastR)
library(gsisdecoder)
library(future)
plan(multisession)
library(dplyr)
library(tidyr)



shinyServer(function(input, output) {
    # Bring in data set
    super <- nflfastR::fast_scraper_schedules(2000:2020) %>%
        dplyr::filter(game_type == "SB") %>%
        dplyr::pull(game_id)
    
    super_bowl <- nflfastR::build_nflfastR_pbp(super)
    
    # Create a cleaned up date column for just the year.
    super_bowl <- super_bowl %>% separate(game_date, into = c("game_year"), sep = "-", remove = FALSE)
    # Bring in super bowl data.
    getData <- reactive({
        yearx_vaue <- input$yearx
        #Show all data - all years.
        if(input$yearx == "All"){
            newData <- super_bowl
            newData
        }
        # Else show specific year chosen.
        else if (input$yearx != "All") {
            newData <- super_bowl %>% filter(game_year == yearx_value)
            newData
        }
    })
    
    # Information for About Page
    #create text info
    output$purpose <- renderText({
        #paste info out
        paste("")
        
    })
    
    
    
})