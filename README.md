This app lets you explore NFL Superbowl Data over the past 20 years.
• A list of packages needed to run the app:
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
library(caret)
library(tidyverse)
library(stats)
library(tree)
• A line of code that would install all the packages used (so we can easily grab that and run it prior to
running your app).
install.packages("shiny")
install.packages("magrittr")
install.packages("nflfastR")
install.packages("gsisdecoder")
install.packages("future")
install.packages("dplyr")
install.packages("tidyr")
install.packages("DT")
install.packages("ggplot2")
install.packages("ggimage")
install.packages("caret")
install.packages("tidyverse")
install.packages("stats")
install.packages("tree")
• The shiny::runGitHub() code that we can copy and paste into RStudio to run your app.
runGitHub("jlrelihan/Final_Project", username = "jlrelihan", ref = "main",
          subdir = "NFL", port = NULL,
          launch.browser = getOption("shiny.launch.browser", interactive()))
