
#Librerias
library(dplyr)
library(corrplot)
library(ggplot2)
library(stargazer)
#library(arm)
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


## DATOS CON TITANIC.CSV
getDataForLogR <- function(){
  #datos <- read.csv("./data/titanic.csv")
  print("entrando")
  datos <- dbGetQuery(conn,"SELECT * FROM titanic")
  datos <- as.data.frame(datos)
  #datos <- rename(datos, Siblings_Spouses = Siblings.Spouses.Aboard)
  #datos <- rename(datos, Parents_Children = Parents.Children.Aboard)
  datos <- rename(datos,  Siblings_Spouses= siblings_spouses_aboard)
  datos <- rename(datos, Parents_Children = parents_children_aboard)
  datos <- mutate(datos, Family_size = Siblings_Spouses+Parents_Children)
  
  
  
  datos <- mutate(datos, Fare_grps = case_when(between(fare, 0, 60) ~ "0-60",  fare > 60 ~ ">60"))
  datos$Class_1 = ifelse(datos$pclass == 1,1,0)
  datos$Class_2 = ifelse(datos$pclass == 2,1,0)
  datos$Class_3 = ifelse(datos$pclass == 3,1,0)
  
  datosLog <- dplyr::select(datos, -fare, -name, -Class_1, -Class_2, -Class_3, -Fare_grps, -Family_size, -id)
  #datosLog <- mutate(datosLog, Pclass = factor(datosLog$Pclass, order=TRUE, levels = c(3, 2, 1)))
  datosLog <- mutate(datosLog, survived = factor(datosLog$survived))
  
  TitanicLog <- glm(survived ~ . , data = datosLog, family = binomial)
  summary(TitanicLog)
  TitanicLog
}

predictp <- predict(getDataForLogR(), type = "response")

single <- data.frame(
  stringsAsFactors = FALSE,
            pclass = c(3L),
               sex = c("female"),
               age = c(31L),
  Siblings_Spouses = c(0L),
  Parents_Children = c(0L)
           )
preduno <- predict(getDataForLogR(), type = "response", newdata = single )


