
server <- function(input, output, session) {
  ########## MODEL 
  #output$value <- renderPrint({ input$edad })
  
  #Prediction
  observeEvent(input$proba, {
    single <- data.frame(
      stringsAsFactors = FALSE,
      pclass = as.numeric(input$clase),
      sex = input$sexo,
      age = input$edad,
      Siblings_Spouses = input$acomp,
      Parents_Children = input$hijos
  )

    sexo <- 0 #male
    if(input$sexo=="female"){sexo=1}

    proba =  resp <- POST('web:8080/getProbaSurvive', body=toJSON(data.frame(age=input$edad, sex=sexo, class=input$clase,
                                                                             companion=input$acomp, children=input$hijos)))
    proba <- content(proba, as='text') 
    output$txtproba <- renderText({ paste0(as.numeric(proba) * 100,"%") })
  })
  
  #Training
  entrena <-function(option="entrenar"){
    POST('web:8080/entrena',body=toJSON(data.frame(option=option)))
  }

  output$entrenado <- renderText(content(entrena("entrenar"),as='text'))

  #Retraining
  observeEvent(input$entrena, {
    output$entrenado <- renderText(content(entrena("Retrain model"),as='text'))
  })
  
  ########### CRUD 
  # Use session$userData to store user data that will be needed throughout
  session$userData$email <- 'aguilaral24@gmail.com'
  
  #Call the server function portion of the `passengers_table_module.R` module file
  callModule(
    passengers_table_module,
    "passengers_table"
  )

  prepareDataDB <- function(datos){
    datos <- rename(datos,  Siblings_Spouses= siblings_spouses_aboard)
    datos <- rename(datos, Parents_Children = parents_children_aboard)
    datos <- mutate(datos, Family_size = Siblings_Spouses+Parents_Children)
    datos
  }
  
  
  ########## VISUALIZATIONS 
  output$corMat <- renderPlot({
    datos <- prepareDataDB(dbGetQuery(conn,"SELECT * FROM titanic"))
    datos %>% 
    dplyr::select(survived,pclass,age,fare,Siblings_Spouses, Parents_Children,Family_size) -> Data
    M <- round(cor(Data),2)
    corrplot::corrplot(M, method="number", type="upper", col= wes_palette("Zissou1"))
  })
   
   output$surv <- renderPlot({
    datos <- prepareDataDB(dbGetQuery(conn,"SELECT * FROM titanic"))
    datos <- mutate(datos, pclass = factor(datos$pclass, order=TRUE, levels = c(3, 2, 1)))
    datos$age = cut(datos$age, c(0,10,20,30,40,50,60,70,80,100))
    datos <- mutate(datos, survived = factor(datos$survived)) %>%
              dplyr::select(survived, VAR = input$VAR )

    cbPalette <- c(    wes_palette("Zissou1") ,"#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")    
    ggplot(datos, aes(x = survived, fill = VAR)) +
    geom_bar(position = position_dodge()) +
    geom_text(stat='count', 
              aes(label=stat(count)), 
              position = position_dodge(width=1), vjust=-0.5) + 
              guides(fill=guide_legend(title=input$VAR)) +
              scale_fill_manual(values = cbPalette ) + 
              scale_x_discrete(labels=c("0" = "No", "1" = "Yes"))
    

  })

  
}
