navbarPage(
  title = 'Titanic',
  theme = bslib::bs_theme(bootswatch = "cerulean"),
  
  #ui de la tab Modelo
  tabPanel('Model',titlePanel(h1("¿Would you survive?", align = 'center')),
           tags$br(),
           tags$br(),

           sidebarLayout(            

             sidebarPanel(
               numericInput("edad", label = "Write down your age", value = 0),
               selectInput("sexo", label = "Select gender", 
                           choices = list("Female" = "female", "Male" = "male"), 
                           selected = "Female"),
               selectInput("clase", label = "Select class", 
                           choices = list("1" = 1, "2" = 2, "3"=3), 
                           selected = "1"),
               numericInput("acomp", label = "Write down number of siblings/spouses aboard", value = 0),
               numericInput("hijos", label = "Write down number of parents/children aboard", value = 0),
               actionButton("proba", "Calculate")
             ),
             
             mainPanel( 
               #withMathJax(h3("Survived ~ class + sex + age + #sibblings/espouse + #children/parents", style = "font-family: papyrus; color:black;")),
             
               sidebarPanel(
                   h5("The probability that you would have survived the Titanic is :" , style = "color:black;"),
                   tags$br(),
                   h4(textOutput("txtproba"), align = 'center'),  
                   style="width:200%"
               ),

               tags$br(),
               tags$br(),

               sidebarPanel(
                actionButton("entrena", "Entrenar modelo"),
                h4(textOutput("entrenado"), align = 'right'), 
                style=""
               )
               
             )
           )
  ),

  #ui de la tab CRUD
  tabPanel('Admin console', titlePanel(h1("CRUD", align = 'center')),
           
           fluidPage(
             shinyFeedback::useShinyFeedback(),
             shinyjs::useShinyjs(),
             passengers_table_module_ui("passengers_table")
           )
           
  ),

  #ui de la tab Visualizaciones
  tabPanel('Visualizations', 
           titlePanel(""),
           
           fluidPage(
             fluidRow(
               column(1,
                      br(),
                      br(),
                      selectInput("VAR", label = "Select:",
                                  choices = list("Sex" = "sex", "Class" = "pclass", "Age" = "age"),
                                  selected = "Sex")
               ),
               column(5, 
                      #histograma
                      h4("Histogram", align = 'center'),
                      br(),
                      plotOutput("surv")
               ),
               
               column(5,
                      #Grafica de correlaciones
                      h4("Correlation atrix", align = 'center'),
                      plotOutput("corMat"),
                      br(),
                      br()
               )
               
             )
 
           )       
  )
)