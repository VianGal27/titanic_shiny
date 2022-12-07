#Librerias
library(dplyr)
library(corrplot)
library(ggplot2)
library(stargazer)
library(MASS)
library(shiny)
library(DT)
library(DBI)
library(shinyjs)
library(shinycssloaders)
library(shinyFeedback)
library(dbplyr)
library(plotly)
library(wesanderson)
library(tidyverse)
library(httr)
library(jsonlite)


## DATOS CON TITANIC POSTGRES
db_config <- config::get()$db

# Create database connection
conn <- dbConnect(
  RPostgres::Postgres(),
  dbname = db_config$db_name,
  host = db_config$db_host,
  port = db_config$db_port,
  user = db_config$db_user,
  password = db_config$db_pass
)

# Stop database connection when application stops
shiny::onStop(function() {
  dbDisconnect(conn)
})

# Turn off scientific notation
options(scipen = 999)

# Set spinner type (for loading)
options(spinner.type = 8)




