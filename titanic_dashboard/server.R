server <- function(input, output, session) {
  ########## modelo
  output$value <- renderPrint({ input$edad })
  
 

  observeEvent(input$proba, {
    single <- data.frame(
      stringsAsFactors = FALSE,
      Pclass = as.numeric(input$clase),
      Sex = input$sexo,
      Age = input$edad,
      Siblings_Spouses = input$acomp,
    Parents_Children = input$hijos
  )
    preduno <- predict(TitanicLog, type = "response", newdata = single )
    
    output$txtproba <- renderText({ preduno })
  })
  
  
  
 ########### CRUD
  #Call the server function portion of the `passengers_table_module.R` module file
  callModule(
    passengers_table_module,
    "passengers_table"
  )

  
  
  ########## visualizaciones
  output$corMat <- renderPlot({
    datos %>% 
    dplyr::select(Survived,Pclass,Age,Fare,Siblings_Spouses, Parents_Children,Family_size) -> Data
    M <- round(cor(Data),2)
    corrplot::corrplot(M, method="number", type="upper", col= wes_palette("Zissou1"))
  })

   output$surv <- renderPlot({
    datos <- mutate(datos, Pclass = factor(datos$Pclass, order=TRUE, levels = c(3, 2, 1)))
    datos$Age = cut(datos$Age, c(0,10,20,30,40,50,60,70,80,100))
    datos <- mutate(datos, Survived = factor(datos$Survived)) %>%
              dplyr::select(Survived, VAR = input$VAR )

    cbPalette <- c(    wes_palette("Zissou1") ,"#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")    
    ggplot(datos, aes(x = Survived, fill = VAR)) +
    geom_bar(position = position_dodge()) +
    geom_text(stat='count', 
              aes(label=stat(count)), 
              position = position_dodge(width=1), vjust=-0.5) + 
              guides(fill=guide_legend(title=input$VAR)) +
              scale_fill_manual(values = cbPalette )
    

  })

  
}
