
#' passenger Delete Module
#'
#' This module is for deleting a row's information from the titanic database file
#'
#' @importFrom shiny observeEvent req showModal h3 modalDialog removeModal actionButton modalButton
#' @importFrom DBI dbExecute
#' @importFrom shinyFeedback showToast
#'
#' @param modal_title string - the title for the modal
#' @param passenger_to_delete string - the model of the passenger to be deleted
#' @param modal_trigger reactive trigger to open the modal (Delete button)
#'
#' @return None
#'
passenger_delete_module <- function(input, output, session, modal_title, passenger_to_delete, modal_trigger) {
  ns <- session$ns
  # Observes trigger for this module (here, the Delete Button)
  observeEvent(modal_trigger(), {
    # Authorize who is able to access particular buttons (here, modules)
    req(session$userData$email == 'aguilaral24@gmail.com')

    showModal(
      modalDialog(
        div(
          style = "padding: 30px;",
          class = "text-center",
          h2(
            style = "line-height: 1.75;",
            paste0(
              '¿Are you sure you want to delete the passenger "',
              passenger_to_delete()$name,
              '"?'
            )
          )
        ),
        title = modal_title,
        size = "m",
        footer = list(
          modalButton("Cancel"),
          actionButton(
            ns("submit_delete"),
            "Delete passenger",
            class = "btn-danger",
            style="color: #fff;"
          )
        )
      )
    )
  })

  observeEvent(input$submit_delete, {
    req(passenger_to_delete())

    removeModal()

    tryCatch({

      id <- passenger_to_delete()$id

      DBI::dbExecute(
        conn,
        "DELETE FROM titanic WHERE id=$1",
        params = c(id)
      )

      session$userData$mtpassengers_trigger(session$userData$mtpassengers_trigger() + 1)
      showToast("success", "¡passenger deleted successfully!")
    }, error = function(error) {

      msg <- "¡Error at deleting passenger!"
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
