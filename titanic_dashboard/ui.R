navbarPage(
  title = 'Titanic',
  theme = bslib::bs_theme(bootswatch = "cerulean"),
  #ui de la tab Modelo
  tabPanel('Model',titlePanel(h1("¿Would you survive?", align = 'center')),
           # Sidebar with a slider input for number of bins 
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
             
             # Show a plot of the generated distribution
             mainPanel(
               #withMathJax(h3("Survived ~ class + sex + age + #sibblings/espouse + #children/parents", style = "font-family: papyrus; color:black;")),
               tags$br(),
               tags$br(),

               h5("The probability that you would have survived the Titanic is :" , style = "color:black;"),
               tags$br(),
               h4(textOutput("txtproba"), align = 'center'),
             
               
             )
           )
  ),
  #ui de la tab CRUD
  tabPanel('Admin console', titlePanel(""),
           
           fluidPage(
             shinyFeedback::useShinyFeedback(),
             shinyjs::useShinyjs(),
             # Application Title
             titlePanel(
               h1("_", align = 'center'),
               windowTitle = "Shiny CRUD Application"
             ),
             passengers_table_module_ui("passengers_table")
           )
           
  ),
  #ui de la tab Visualizaciones
  tabPanel('Visualizations', 
           titlePanel(""),
           
           fluidPage(
             
            
             fluidRow(
               column(1,
                      h4("Histogram", align = 'center'),
                      selectInput("VAR", label = "Select:",
                                  choices = list("Sex" = "sex", "Class" = "pclass", "Survived" = "age"),
                                  selected = "Sex"),
               ),
               column(5, 
                      h4("_", align='center'),
                      plotOutput("surv")
               ),
               
               column(5,
               
                 # Show a plot of the generated distribution
                 h4("Correlation atrix", align = 'center'),
                 plotOutput("corMat"),
                 tags$br(),
                 tags$br(),
               )
               
             ),
             
             
             
           )       
  )
)