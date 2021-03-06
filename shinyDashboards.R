library(shiny)
library(shinydashboard)
library(leaflet)
library(googlesheets)



###
# Component - Side Menu
###
mainsidemenu<- sidebarMenu(
  menuItem("Tab1", tabName = "Tab1", icon = icon("dashboard")),
  menuItem("Tab2", tabName = "Tab2", icon = icon("th")),
  textInput("Id", "Label"),
  sliderInput("slider", "Slider input:", 1, 100, 50)
)

###
# Component - Tab Pages
###
tab1<- tabItem(tabName = "Tab1",
               leafletOutput("simplemap", height = 500)
)

tab2<- tabItem(tabName = "Tab2",
               h2("Other tab content. This will show when you click on the Second tab."),
               infoBoxOutput("approvalBox"),
               
               box(
                 title = "Inputs",background = "black", status = "warning",
                 "Box content here", br(), "More box content",
                 sliderInput("slider", "Slider input:", 1, 100, 50),
                 textInput("text", "Text input:")
               )
               
               
)

###############################################################################
###
# Creating UI
###
header <- dashboardHeader(title = "First Dashboard",dropdownMenuOutput("messageMenu"))
sidebar <- dashboardSidebar(mainsidemenu)
body <- dashboardBody(tabItems(tab1,tab2))

ui <- dashboardPage(header,sidebar,body,skin = "red")


###
# Creating SERVER
###
tasks<- gs_read(ss=gs_title("absolute rough"),ws="tasklist")

server <- function(input, output) { 
  
  output$messageMenu <- renderMenu({
    messageData<- data.frame(value=tasks$status,color="yellow",text=tasks$task)
    msgs <- apply(messageData, 1, function(row) {
      taskItem(value = row[["value"]], color = row[["color"]], text = row[["text"]])
    })
    
    dropdownMenu(type = "tasks", .list = msgs)
  })
  
  output$approvalBox <- renderInfoBox({
    infoBox(
      "Approval", "80%", icon = icon("thumbs-up", lib = "glyphicon"),
      color = "yellow"
    )
  })
  
  output$simplemap <- renderLeaflet({
    df<- gs_read(gs_title("absolute rough"),ws="locationList")
    leaflet(df) %>% addTiles() %>% addMarkers(popup = df$Name)%>%  
      addCircles(radius = 3000,color = df$Name)
  })
  
  
  
}# end of server function

shinyApp(ui, server)
