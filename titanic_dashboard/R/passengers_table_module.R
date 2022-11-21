#' passengers Table Module UI
#'
#' The UI portion of the module for displaying the titanic datatable
#'
#' @importFrom shiny NS tagList fluidRow column actionButton tags
#' @importFrom DT DTOutput
#' @importFrom shinycssloaders withSpinner
#'
#' @param id The id for this module
#'
#' @return a \code{shiny::\link[shiny]{tagList}} containing UI elements
#'
passengers_table_module_ui <- function(id) {
  ns <- NS(id)

  tagList(
    fluidRow(
      column(
        width = 2,
        actionButton(
          ns("add_passenger"),
          "Add",
          class = "btn-success",
          style = "color: #fff;",
          icon = icon('plus'),
          width = '100%'
        ),
        tags$br(),
        tags$br()
      )
    ),
    fluidRow(
      column(
        width = 12,
        title = "",
        DTOutput(ns('passenger_table')) %>%
          withSpinner(),
        tags$br(),
        tags$br()
      )
    ),
    tags$script(src = "passengers_table_module.js"),
    tags$script(paste0("passengers_table_module_js('", ns(''), "')"))
  )
}

#' passengers Table Module Server
#'
#' The Server portion of the module for displaying the titanic datatable
#'
#' @importFrom shiny reactive reactiveVal observeEvent req callModule eventReactive
#' @importFrom DT renderDT datatable replaceData dataTableProxy
#' @importFrom dplyr tbl collect mutate arrange select filter pull
#' @importFrom purrr map_chr
#' @importFrom tibble tibble
#'
#' @param None
#'
#' @return None

passengers_table_module <- function(input, output, session) {

  # trigger to reload data from the titanic table
  session$userData$mtpassengers_trigger <- reactiveVal(0)

  # Read in titanic table from the database
  passengers <- reactive({
    session$userData$mtpassengers_trigger()

    out <- NULL
    tryCatch({
      out <- 
        dbGetQuery(conn,"SELECT * FROM titanic")
    }, error = function(err) {


      msg <- "Database Connection Error"
      # print `msg` so that we can find it in the logs
      print(msg)
      # print the actual error to log it
      print(error)
      # show error `msg` to user.  User can then tell us about error and we can
      # quickly identify where it cam from based on the value in `msg`
      showToast("error", msg)
    })

    out
  })


  passenger_table_prep <- reactiveVal(NULL)

  observeEvent(passengers(), {
    out <- passengers()

    ids <- out$id

    actions <- purrr::map_chr(ids, function(id_) {
    #actions <- purrr::map_chr(out$name, function(id_) {
      paste0(
        '<div class="btn-group" style="width: 75px;" role="group" aria-label="Basic example">
          <button class="btn btn-primary btn-sm edit_btn" data-toggle="tooltip" data-placement="top" title="Edit" id = ', id_, ' style="margin: 0"><i class="fa fa-pencil-square-o"></i></button>
          <button class="btn btn-danger btn-sm delete_btn" data-toggle="tooltip" data-placement="top" title="Delete" id = ', id_, ' style="margin: 0"><i class="fa fa-trash-o"></i></button>
        </div>'
      )
    })

    #Remove the `id` column. We don't want to show this column to the user
      out <- out %>%
        dplyr::select(-id)

    # Set the Action Buttons row to the first column of the titanic table
    out <- cbind(
      tibble(" " = actions),
      out
    )

    if (is.null(passenger_table_prep())) {
      # loading data into the table for the first time, so we render the entire table
      # rather than using a DT proxy
      passenger_table_prep(out)

    } else {

      # table has already rendered, so use DT proxy to update the data in the
      # table without rerendering the entire table
      replaceData(passenger_table_proxy, out, resetPaging = FALSE, rownames = FALSE)

    }
  })

  output$passenger_table <- renderDT({
    req(passenger_table_prep())
    out <- passenger_table_prep()

    datatable(
      out,
      rownames = FALSE,
      colnames = c('survived', 'pclass', 'name', 'sex','age','siblings_spouses_aboard','parents_children_aboard','fare'),
      selection = "none",
      class = "compact stripe row-border nowrap",
      # Escape the HTML in all except 1st column (which has the buttons)
      escape = -1,
      extensions = c("Buttons"),
      options = list(
        scrollX = TRUE,
        dom = 'Bftip',
        buttons = list(
          list(
            extend = "excel",
            text = "Download",
            title = paste0("mtpassengers-", Sys.Date()),
            exportOptions = list(
              columns = 1:(length(out) - 1)
            )
          )
        ),
        columnDefs = list(
          list(targets = 0, orderable = FALSE)
        ),
        drawCallback = JS("function(settings) {
          // removes any lingering tooltips
          $('.tooltip').remove()
        }")
      )
    ) #%>%
    #  formatDate(
    #    columns = c("created_at", "modified_at"),
    #    method = 'toLocaleString'
    #  )

  })

  passenger_table_proxy <- DT::dataTableProxy('passenger_table')

  callModule(
    passenger_edit_module,
    "add_passenger",
    modal_title = "Add passenger",
    passenger_to_edit = function() NULL,
    modal_trigger = reactive({input$add_passenger})
  )

  passenger_to_edit <- eventReactive(input$passenger_id_to_edit, {
    passengers() %>%
      filter(id == input$passenger_id_to_edit)
  })

  callModule(
    passenger_edit_module,
    "edit_passenger",
    modal_title = "Edit passenger",
    passenger_to_edit = passenger_to_edit,
    modal_trigger = reactive({input$passenger_id_to_edit})
  )

  passenger_to_delete <- eventReactive(input$passenger_id_to_delete, {
    passengers() %>%
      filter(id == input$passenger_id_to_delete) %>%
      as.list()
  })

  callModule(
    passenger_delete_module,
    "delete_passenger",
    modal_title = "Delete passenger",
    passenger_to_delete = passenger_to_delete,
    modal_trigger = reactive({input$passenger_id_to_delete})
  )

}
