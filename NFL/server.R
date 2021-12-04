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
    super <- nflfastR::fast_scraper_schedules(2000:2020) %>%
        dplyr::filter(game_type == "SB") %>%
        dplyr::pull(game_id)
    
    super_bowl <- nflfastR::build_nflfastR_pbp(super)
    
    # Create a cleaned up date column for just the year.
    super_bowl <- super_bowl %>% separate(game_date, into = c("game_year"), sep = "-", remove = FALSE)

    
    # Information for About Page
    #create text info
    output$purpose <- renderText({
        #paste info out
        paste("")
        
    })
    
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
    
    })