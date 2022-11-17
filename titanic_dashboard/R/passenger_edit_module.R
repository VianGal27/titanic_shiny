
#' Passenger Add & Edit Module
#'
#' Module to add & edit passengers in the titanic database
#'
#' @importFrom shiny observeEvent showModal modalDialog removeModal fluidRow column textInput numericInput selectInput modalButton actionButton reactive eventReactive
#' @importFrom shinyFeedback showFeedbackDanger hideFeedback showToast
#' @importFrom shinyjs enable disable
#' @importFrom lubridate with_tz
#' @importFrom uuid UUIDgenerate
#' @importFrom DBI dbExecute
#'
#' @param modal_title string - the title for the modal
#' @param passenger_to_edit reactive returning a 1 row data frame of the passenger to edit ' from the titanic table
#' @param modal_trigger reactive trigger to open the modal (Add or Edit buttons)
#'
#' @return None
#'
passenger_edit_module <- function(input, output, session, modal_title, passenger_to_edit, modal_trigger) {
  ns <- session$ns

  observeEvent(modal_trigger(), { 
    hold <- passenger_to_edit()
    
    showModal(
      modalDialog(
        fluidRow(
          column(
            width = 6,
            selectInput(
              ns("survived"),
              'Survived',
              choices = c('Yes', 'No'),
              selected = ifelse(is.null(hold), "", hold$survived)
            ),
            selectInput(
              ns('pclass'),
              'Class',
              choices = c('1', '2','3'),
              selected = ifelse(is.null(hold), "", hold$pclass)
            ),
            textInput(
              ns('name'),
              'Name',
              value = ifelse(is.null(hold), "", hold$name)
            ),
            selectInput(
              ns('sex'),
              'Sexo',
              choices = c('male', 'female'),
              selected = ifelse(is.null(hold), "", hold$sex)
            )
          ),
          column(
            width = 6,
            numericInput(
              ns('age'),
              'Age',
              value = ifelse(is.null(hold), "0", hold$age),
              min = 0,
              step = 1,
              max = 100
            ),
            numericInput(
              ns('siblings_spouses_aboard'),
              'Siblings and/or spouses aboard',
              value = ifelse(is.null(hold), "0", hold$siblings_spouses_aboard),
              min = 0,
              step = 1,
              max = 20 
            ),
            numericInput(
              ns('parents_children_aboard'),
              'Parents and/or children aboard',
              value = ifelse(is.null(hold), "0", hold$parents_children_aboard),
              min = 0,
              step = 1,
              max = 20 
            ),
            numericInput(
              ns('fare'),
              'Fare',
              value = ifelse(is.null(hold), "0", hold$fare),
              min = 0,
              max = 600,
              step = 0.1
            ),
          )
        ),
        title = modal_title,
        size = 'm',
        footer = list(
          modalButton('Cancel'),
          actionButton(
            ns('submit'),
            'Submit',
            class = "btn btn-primary",
            style = "color: white"
          )
        )
      )
    )

    # Observe event for "Model" text input in Add/Edit passenger Modal
    # `shinyFeedback`
    observeEvent(input$name, {
      if (input$name == "") {
        shinyFeedback::showFeedbackDanger(
          "name",
          text = "Must enter passenge's name!"
        )
        shinyjs::disable('submit')
      } else {
        shinyFeedback::hideFeedback("name")
        shinyjs::enable('submit')
      }
    })

  })





  edit_passenger_dat <- reactive({
    hold <- passenger_to_edit()

    out <- list(
      id = if (is.null(hold)) NA else hold$id,
      #uid = NA,
      data = list(
        "survived" = ifelse(input$survived=='Yes',"1","0"),
        "pclass" = input$pclass,
        "name" = input$name,
        "sex" = input$sex,
        "age" = input$age,
        "siblings_spouses_aboard" = input$siblings_spouses_aboard,
        "parents_children_aboard" = input$parents_children_aboard,
        "fare" = input$fare
      )
    )
  
    #time_now <- as.character(lubridate::with_tz(Sys.time(), tzone = "UTC"))

    if (is.null(hold)) {
      # adding a new passenger

      #out$data$created_at <- time_now
      #out$data$created_by <- session$userData$email
    } else {
      # Editing existing passenger

      #out$data$created_at <- as.character(hold$created_at)
      #out$data$created_by <- hold$created_by
    }

    #out$data$modified_at <- time_now
    #out$data$modified_by <- session$userData$email

    out
  })

  validate_edit <- eventReactive(input$submit, {
    dat <- edit_passenger_dat()

    # Logic to validate inputs...

    dat
  })

  observeEvent(validate_edit(), {
    removeModal()
    dat <- validate_edit()

    tryCatch({
   
      if (is.na(dat$id)) {
        # creating a new passenger
        #uid <- uuid::UUIDgenerate()
        id <- dbGetQuery(conn,"select max(id) from titanic")[[1]] +1
        print(id)
        dbExecute(
          conn,
          "INSERT INTO titanic (survived,pclass,name,sex,age,siblings_spouses_aboard,parents_children_aboard,fare,id)
          VALUES($1, $2, $3, $4, $5, $6, $7, $8, $9)",
          params = c(
            #list(uid),
            unname(dat$data),
            id
          )
        )
      #  dbGetQuery(conn, "INSERT INTO titanic (survived,pclass,name,sex,age,siblings_spouse_aboard,parents_children_aboard,fare)
       #                   VALUES(" + unname(dat$data) +")")
      } else {
         #editing an existing passenger
        dbExecute(
          conn,
          "UPDATE titanic SET survived=$1, pclass=$2, name=$3, sex=$4, age=$5, siblings_spouses_aboard=$6,
          parents_children_aboard=$7, fare=$8 WHERE id=$9",
          params = c(
            unname(dat$data),
            list(dat$id)
          )
        )
      }

      session$userData$mtpassengers_trigger(session$userData$mtpassengers_trigger() + 1)
      showToast("success", paste0(modal_title, " Successs"))
    }, error = function(error) {

      msg <- paste0(modal_title, " Error")


      # print `msg` so that we can find it in the logs
      print(msg)
      # print the actual error to log it
      print(error)
      # show error `msg` to user.  User can then tell us about error and we can
      # quickly identify where it cam from based on the value in `msg`
      showToast("error", msg)
    })
  })

}
