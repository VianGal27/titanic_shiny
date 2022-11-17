navbarPage(
  title = 'Titanic',
  theme = bslib::bs_theme(bootswatch = "cerulean"),
  #ui de la tab Modelo
  tabPanel('Modelo',titlePanel(h1("Modelo LOGIT", align = 'center')),
           # Sidebar with a slider input for number of bins 
           sidebarLayout(
             sidebarPanel(
               numericInput("edad", label = "Ingresa tu edad", value = 0),
               selectInput("sexo", label = "Selecciona tu sexo", 
                           choices = list("Mujer" = "female", "Hombre" = "male"), 
                           selected = "Mujer"),
               selectInput("clase", label = "Selecciona tu clase", 
                           choices = list("1" = 1, "2" = 2, "3"=3), 
                           selected = "1"),
               numericInput("acomp", label = "Número de hermanos y/o cónyuges que te acompañan", value = 0),
               numericInput("hijos", label = "Número de padres y/o hijos que te acompañan", value = 0),
               actionButton("proba", "Calcular")
             ),
             
             # Show a plot of the generated distribution
             mainPanel(
               withMathJax(h3("Survived ~ class + sex + age + #sibblings/espouse + #children/parents", style = "font-family: papyrus; color:black;")),
               tags$br(),
               tags$br(),

               h5("La probabilidad de que hubieras sobrevivido en el accidente del Titanic es:" , style = "color:black;"),
               tags$br(),
               h4(textOutput("txtproba"), align = 'center'),
             
               
             )
           )
  ),
  #ui de la tab CRUD
  tabPanel('CRUD', titlePanel(""),
           
           fluidPage(
             shinyFeedback::useShinyFeedback(),
             shinyjs::useShinyjs(),
             # Application Title
             titlePanel(
               h1("Database", align = 'center'),
               windowTitle = "Shiny CRUD Application"
             ),
             passengers_table_module_ui("passengers_table")
           )
           
  ),
  #ui de la tab Visualizaciones
  tabPanel('Visualizaciones', 
           titlePanel(""),
           
           fluidPage(
             
             # Show a plot of the generated distribution
               h4("Matriz de Correlaciones", align = 'center'),
               plotOutput("corMat"),
               tags$br(),
               tags$br(),
               h4("Histograma", align = 'center'),
               fluidRow(
                 column(3,
                        selectInput("VAR", label = "Selecciona la variable",
                                     choices = list("Sex" = "Sex", "Class" = "Pclass", "Age" = "Age"),
                                     selected = "Sex"),
                 ),
                 column(9, 
                        plotOutput("surv")
                 )
               ),
             
           )       
  )
)