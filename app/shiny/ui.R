
navbarPage(
  title = 'Titanic',
  theme = bslib::bs_theme(bootswatch = "cerulean"),
  
  ### MODEL TAB UI
  tabPanel('Model',titlePanel(h1("¿Would you survive?", align = 'center')),
           tags$br(),
           tags$br(),

           sidebarLayout(            
            #variables to use as a new observation to be predicted 
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
              #Prediction of a new observation              
               sidebarPanel(
                   h5("The probability that you would have survived the Titanic is :" , style = "color:black;"),
                   tags$br(),
                   tags$br(),
                   h4(textOutput("txtproba"), align = 'center'),  
                   style="width:200%"
               ),

               tags$br(),
               tags$br(),
              #Retraining of the model 
               sidebarPanel(
                actionButton("entrena", "Retrain model"),
                h4(textOutput("entrenado"), align = 'right'), 
                style=""
               ),
               img(src="titanic.jpeg",height = '345px', width = '490px',align = 'right')
             )
           )
  ),

  #### CRUD TAB UI
  tabPanel('Admin console', titlePanel(h1("CRUD", align = 'center')),
           #datatable with titanic info
           fluidPage(
             shinyFeedback::useShinyFeedback(),
             shinyjs::useShinyjs(),
             passengers_table_module_ui("passengers_table")
           )
           
  ),

  ### VISUALIZATIONS TAB UI
  tabPanel('Visualizations', 
           titlePanel(""),
           
           fluidPage(
             fluidRow(
               column(1,
                      #Histogram control variable input
                      br(),
                      br(),
                      selectInput("VAR", label = "Select:",
                                  choices = list("Sex" = "sex", "Class" = "pclass", "Age" = "age"),
                                  selected = "Sex")
               ),
               column(5, 
                      #Histogram plots
                      h4("Histogram", align = 'center'),
                      br(),
                      plotOutput("surv")
               ),
               
               column(5,
                      #Correlation plot
                      h4("Correlation Matrix", align = 'center'),
                      plotOutput("corMat"),
                      br(),
                      br()
               )
               
             )
 
           )       
  )
)