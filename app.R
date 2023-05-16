library(shiny)
library(RSQLite)
library(tidyverse)
library(lubridate)
library(emo)
library(shinyjs)
library(DT)
library(bslib)
library(shinycustomloader)
library(shinyWidgets)

databaseName = "Applications"
tableName = "Positions"
otherTable = "Updates"
finalTable = "Results"
requiredFields = c("positionTitle", 
                   "companyName")
allFields = c(requiredFields,
              "roleDescription",
              "appliedDate",
              "tags", 
              "addlNotes")
updatesReqFields = c("ID", 
                     "status")
updatesAllFields = c(updatesReqFields, 
                     "notes")

addResponses <- function(data, table) {
  db <- dbConnect(SQLite(), databaseName)
  query <- sprintf("INSERT INTO %s (%s) VALUES ('%s')", table,
                   paste(names(data), collapse = ", "),
                   paste(data, collapse = "', '"))
  dbGetQuery(db, query)
  dbDisconnect(db)
}

loadResponses <- function() {
  db <- dbConnect(SQLite(), databaseName)
  query <- sprintf("SELECT * FROM %s", tableName)
  data <- dbGetQuery(db, query)
  dbDisconnect(db)
  data
}


listOfTags = c(paste0(emo::ji("heart"), "Favorite"), 
               paste0(emo::ji("purple heart"), "Hopeful"), 
               paste0(emo::ji("cross mark"), "Long shot"), 
               paste0(emo::ji("question"), "Preferred qualifs. not met"), 
               paste0(emo::ji("woman_technologist"), "Remote"))


ui = page_navbar(title = strong("Internship Database"),
                 id = "nav",
                 shinyjs::useShinyjs(),
                 includeCSS("www/styles.css"),
                 br(),
                 
                 nav(title = strong("Create Entries"),
                   layout_sidebar(sidebar(width = "330",
                                          div(id = "form",
                                              dateInput("appliedDate",
                                                        label = "Date applied",
                                                        value = today(),
                                                        max = today(),
                                                        format = "mm-dd-yyyy"),
                                              textInput("positionTitle",
                                                         label = "Position",
                                                         placeholder = "Data Science Intern"),
                                              textInput("companyName",
                                                         label = "Company",
                                                         placeholder = "Chevron"),
                                              textAreaInput("roleDescription",
                                                             label = "Role description",
                                                             placeholder = "Your responsibilities include...",
                                                             resize = "vertical"),
                                              checkboxGroupInput("tags",
                                                                  label = "Tags",
                                                                  choiceNames = listOfTags,
                                                                  choiceValues = listOfTags),
                                              textAreaInput("addlNotes",
                                                             label = "Additional notes",
                                                             placeholder = "Any other important things to know about this role",
                                                             resize = "vertical"),
                                              actionButton("submitButton",
                                                            label = "Submit"))
               ),
               column(12,
                 actionButton("info", 
                              icon = icon("info"), 
                              label = " Navigation"), 
                 align = "right"
               ),
               h3(strong("Your Internships")),
               br(),
               downloadButton("downloadButton",
                              label = "Download Table"),
               br(), br(),
               dataTableOutput("responsesTable"),
               br())), 
               nav(title = strong("Track Offers/Rejections"), 
                   layout_sidebar(
                     sidebar(
                       width = 330, 
                       div(id = "updateForm",
                         textInput("ID", 
                                   label = "ID"),
                         radioButtons("status",
                                      label = "Status", 
                                      choices = c("Accepted" = "Accepted", 
                                                  "Rejected" = "Rejected"), 
                                      selected = "Rejected"), 
                         textAreaInput("notes", 
                                       label = "Additional notes", 
                                       resize = "vertical"), 
                         actionButton("submitUpdate", 
                                      label = "Submit"))
                     ), 
                     h3(strong("Your Internship Statuses")),
                     br(), 
                     downloadButton("downloadResults", 
                                    label = "Download Table"), 
                     br(), br(),
                     dataTableOutput("updatesTable")
                   )), 
               nav(title = strong("Filter Entries"), 
                   layout_sidebar(
                     sidebar(# position = "right", 
                       width = "330",
                       # open = TRUE, 
                       textAreaInput("query", 
                                     label = "Your query", 
                                     resize = "vertical"), 
                       actionButton("submitQuery", 
                                    label = "Submit"), 
                       hr(),
                       strong(helpText("Database information")),
                       helpText(
                         tags$ul(
                           tags$li(paste0("Positions: ", paste0(c("ID", allFields), collapse = ", "))), 
                           tags$li(paste0("Updates: ID, status, notes")), 
                           tags$li(paste0("Results: ID, positionTitle, companyName, tags, status, notes"))
                         )
                       ),
                       # hr(), 
                       # actionButton("clearFilters", 
                       #              label = "Clear filters"),
                     ),
                     conditionalPanel(
                       condition = "input.submitQuery == 0", 
                       br(), 
                       p(strong(HTML("<center>No filters applied</center>")))
                     ),
                     conditionalPanel(
                       condition = "input.submitQuery > 0",
                       h3(strong("Filtered Table")),
                       br(), 
                       downloadButton("downloadQuery", 
                                      label = "Download Table",
                                      style = "width: 160px"),
                       br(), br(),
                       dataTableOutput("queryTable")
                     )
                     # border = FALSE
                   )
               )
)

server = function(input, output) {
  
  # enabling the Submit button (only) when the required fields are filled out
  observe({
    reqFieldsFilled = requiredFields %>%
      sapply(function(x) !is.null(input[[x]]) && input[[x]] != "") %>%
      all
    
    shinyjs::toggleState("submitButton", reqFieldsFilled)
  })
  
  # gathering all input data (used as parameter for addResponses)
  inputData = reactive({
   data = sapply(allFields, function(x) as.character(HTML(paste0(input[[x]], collapse = "<br/>"))))
  })
  
  observeEvent(input$submitButton, {
    shinyjs::disable("submitButton")
    addResponses(inputData(), tableName)
    shinyjs::reset("form")
    on.exit({
      shinyjs::enable("submitButton")
    })
  })
  
  # updating the responses whenever a new submission is made 
  responses_data <- reactive({
    input$submitButton
    loadResponses()
  })
  
  # displaying the responses in a table
  output$responsesTable <- DT::renderDataTable({
    DT::datatable(
      responses_data(),
      rownames = FALSE,
      escape = F,
      colnames = c("Date" = "appliedDate", 
                   "Position" = "positionTitle", 
                   "Company" = "companyName", 
                   "Description" = "roleDescription", 
                   "Tags" = "tags",  
                   "Notes" = "addlNotes"),
      options = list(scrollX = TRUE, 
                     pageLength = 5,
                     search.regex = TRUE,
                     columnDefs = (list(list(width = '110px', targets = c("appliedDate")), 
                                        list(width = "150px", targets = c("positionTitle", "companyName")), 
                                        list(width = "250px", targets = c("tags")),
                                        list(width = "325px", targets = c("roleDescription", "addlNotes")))))
    )
  })
  
  # downloading the table
  output$downloadButton <- downloadHandler(
    filename = function() { 
      paste0(databaseName, ".", tableName, "_", today(), '.csv')
    },
    content = function(file) {
      write.csv(responses_data(), file, row.names = FALSE)
    }
  )
  
  # enable submit button only if query is not empty
  observe ({
    queryExists = !is.null(input$query) && input$query != ""
    shinyjs::toggleState("submitQuery", queryExists)
  })
  
  query_data = eventReactive(input$submitQuery, {
    shinyjs::disable("submitQuery")
    on.exit({
      shinyjs::enable("submitQuery")
    })
    db = dbConnect(SQLite(), databaseName)
    data = dbGetQuery(db, input$query)
    dbDisconnect(db)
    data
  })
  
  output$queryTable = renderDataTable({
    if (grepl("SELECT * FROM POSITIONS", str_to_upper(input$query), fixed = T)) {
      columnDefs = (list(list(width = '110px', targets = c("appliedDate")), 
                         list(width = "150px", targets = c("positionTitle", "companyName")), 
                         list(width = "250px", targets = c("tags")),
                         list(width = "325px", targets = c("roleDescription", "addlNotes"))))
    }
    else if (grepl("SELECT * FROM RESULTS", str_to_upper(input$query), fixed = T)) {
      columnDefs = (list(list(width = "300px", targets = c("positionTitle", "companyName", "tags")), 
                         list(width = "350px", targets = c("notes"))))
    }
    else {
      columnDefs = NULL
    }
    DT::datatable(
      query_data(),
      rownames = FALSE,
      escape = F, 
      options = list(scrollX = TRUE,
                     pageLength = 5,
                     search.regex = TRUE,
                     columnDefs = columnDefs
                     )
    )
  })
  
  output$downloadQuery <- downloadHandler(
    filename = function() { 
      paste0(databaseName, ".Queried", tableName, "_", today(), '.csv')
    },
    content = function(file) {
      write.csv(query_data(), file, row.names = FALSE)
    }
  )
  
  observe({
    validUpdate = !is.null(input$ID) && input$ID != ""

    shinyjs::toggleState("submitUpdate", validUpdate)
  })
  
  updateInpData = reactive({
    data = sapply(updatesAllFields, 
                  function(x) as.character(HTML(paste0(input[[x]], 
                                                       collapse = "<br/>"))))
  })
  
  observeEvent(input$submitUpdate, {
    shinyjs::disable("submitUpdate")
    addResponses(updateInpData(), otherTable)
    db <- dbConnect(SQLite(), databaseName)
    query = paste0(
      "INSERT INTO ", finalTable, "(ID, positionTitle, companyName, tags, status, notes) ", 
      "SELECT u.ID, p.positionTitle, p.companyName, p.tags, u.status, u.notes ", 
      "FROM ", otherTable, " u ", 
      "LEFT JOIN ", tableName, " p ", 
      "ON u.ID = p.ID ", 
      "WHERE u.ID = ", input$ID, ";"
    )
    dbGetQuery(db, query)
    dbDisconnect(db)
    shinyjs::reset("updateForm")
    on.exit({
      shinyjs::enable("submitUpdate")
    })
  })
  
  results_data = reactive({
    input$submitUpdate
    db = dbConnect(SQLite(), databaseName)
    query = sprintf("SELECT * FROM %s", finalTable)
    data = dbGetQuery(db, query)
    data
  })
  
  output$updatesTable = renderDataTable({
    DT::datatable(
      results_data(), 
      rownames = FALSE,
      escape = F, 
      colnames = c("Position" = "positionTitle", 
                   "Company" = "companyName", 
                   "Tags" = "tags",  
                   "Status" = "status",
                   "Notes" = "notes"), 
      options = list(scrollX = TRUE, 
                     pageLength = 5,
                     search.regex = TRUE,
                     columnDefs = (list(list(width = "300px", targets = c("positionTitle", "companyName", "tags")), 
                                        list(width = "350px", targets = c("notes")))))
    )
  })
  
  output$downloadResults <- downloadHandler(
    filename = function() { 
      paste0(databaseName, ".", finalTable, "_", today(), '.csv')
    },
    content = function(file) {
      write.csv(results_data(), file, row.names = FALSE)
    }
  )
  observeEvent(
    eventExpr = input$info,
    handlerExpr = {
      sendSweetAlert(
        # session = session,
        # type = "info",
        closeOnClickOutside = T,
        title = "Info",
        text = tags$span(
          "Welcome to ", strong("Internship Database,"), "your home base for managing internship applications! All responses are hosted locally in a SQLite database." ,
              br(), br(),
              "About each tab:",
              tags$ul(
                tags$li(tags$u("Create Entries:"), "enter information about each internship you apply for"),
                tags$li(tags$u("Track Offers/Rejections:"), "track the internships you've heard back from"),
                tags$li(tags$u("Filter Entries:"), "use SQLite commands to filter or alter tables")
              )
        ),
        html = TRUE # you must include this new argument
      )
    }
  )
  
}

shinyApp(ui = ui, server = server)