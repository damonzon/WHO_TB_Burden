library(shiny)
library(shinydashboard)
library(data.table)
library(ggplot2)
library(plotly)
#Read data from GitHub (select 4 variables)
tb_data <- fread("https://raw.githubusercontent.com/datamustekeers/WHOtb_data_analysis/master/data/TB_burden_countries_2018-07-04.csv",
           select=c(1,6:7,11))
names(tb_data) <- c("country", "year","population","tb_cases")
tb_data$population <- round(tb_data$population/1e+6,2)
tb_data$incidence <- round((tb_data$tb_cases*0.1)/tb_data$population,1)
all_countries = unique(tb_data$country)

ui <- shinyUI(dashboardPage(
  dashboardHeader(title = "WHO TB Burden"),
  dashboardSidebar(sidebarMenu(
    menuItem(
      "Dashboard",
      tabName = "dashboard",
      icon = icon("dashboard")
    ),
    menuItem("Widgets", tabName = "widgets", icon = icon("th")),
    uiOutput("Choose_country")
  )),
  dashboardBody(tabItems(
    # First tab content
    tabItem(
      tabName = "dashboard",
      fluidRow(
        infoBox("Data Available for", paste("218","Countries"), icon = icon("globe", lib = "glyphicon")),
        infoBoxOutput("Country_Selected"),
        infoBoxOutput("Pop_Figures")
      ),
      
      fluidRow(
        infoBoxOutput("Pop_Growth"),
        infoBoxOutput("TB_Figures"),
        infoBoxOutput("TB_Growth")
      ),
      
      fluidRow(
        box(
          title = "Population By Year",
          status = "primary",
          solidHeader = TRUE,
          plotlyOutput("plot1", height = 400)
        ),
        box(
          title = "Incidence of Tb Cases By Year",
          status = "primary",
          solidHeader = TRUE,
          plotlyOutput("plot2", height = 400)
        )
      )
    ),
    
    # Second tab content
    tabItem(tabName = "widgets",
            h2("Widgets tab content"))
  ))
))

server <- shinyServer(function(input, output) {
  output$Choose_country <- renderUI({
    selectInput("select",
                "Select a country",
                choices = all_countries,
                selected = all_countries[1])
  })
  
  get_data <- reactive({
    #Get User selection
    country_selected = input$select
    #select data before intiating selector.
    country_data = subset(tb_data, country == country_selected)
    country_data  = country_data[, c("year", "population", "incidence","tb_cases")]
    return(country_data)
  })
  
  output$Country_Selected <- renderInfoBox({
    my_country = input$select
    infoBox("Country Selected",my_country, icon = icon("pushpin", lib = "glyphicon"),color = "aqua")
  })
  
  output$Pop_Figures <- renderInfoBox({
    country_data = get_data()
    infoBox("Population (Millions)",
      tags$p(paste("2000:",paste(country_data[1, 2]), "\n2016:",paste(country_data[17, 2])), style = "font-size: 14Px"),
      icon = icon("user", lib = "glyphicon"),
      color = "aqua"
    )
  })
  
  output$Pop_Growth <- renderInfoBox({
    country_data = get_data()
    infoBox(
      "Population Growth (2000-2016)",
      paste(round((((country_data[17, 2] - country_data[1, 2]) / (country_data[1, 2])
      ) * 100), 0), "%"),
      icon = icon("sort", lib = "glyphicon"),
      color = "maroon"
    )
  })
  
  output$TB_Figures <- renderInfoBox({
    country_data = get_data()
    infoBox(
      "New Tuberculosis Cases",
      tags$p(paste("2000 = ",paste(country_data[1, 4]), "2016 = ",paste(country_data[17, 4])), style = "font-size: 12Px"),
            icon = icon("alert", lib = "glyphicon"),
      color = "maroon"
    )
  })
  
  output$TB_Growth <- renderInfoBox({
    country_data = get_data()
    infoBox(
      "Overall Trend in TB Incidence",
      paste(round((((country_data[17, 3] - country_data[1, 3]) / (country_data[1, 3])
      ) * 100), 0), "%"),
      icon = icon("dashboard", lib = "glyphicon"),
      color = "maroon"
    )
  })
  
  output$plot1 <- renderPlotly({
    country_data = get_data()
    p= ggplot(data = country_data, aes(x = year, y = population)) +
      geom_line(linetype = "dashed", color = "#900C3F") +
      geom_point(color = "#900C3F") +
      labs(x = "Year", y = "Population in Millions") +
      theme(
        axis.text = element_text(
          face = "bold",
          color = "#340B02",
          size = 14
        ),
        axis.title = element_text(
          face = "bold",
          color = "#340B02",
          size = 14
        )
      )
    ggplotly(p) %>% config(displayModeBar = F)
  })
  
  output$plot2 <- renderPlotly({
    country_data = get_data()
    p = ggplot(data = country_data, aes(x = year, y = incidence)) +
      geom_line(linetype = "dashed", color = "#900C3F") +
      geom_point(color = "#900C3F") +
      labs(x = "Year", y = "New Cases per 100,000 Pop") +
      theme(
        axis.text = element_text(
          face = "bold",
          color = "#340B02",
          size = 14
        ),
        axis.title = element_text(
          face = "bold",
          color = "#340B02",
          size = 14
        )
      )
    ggplotly(p) %>% config(displayModeBar = F)
  })
})

shinyApp(ui = ui, server = server)
