
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(SmarterPoland)
library(RColorBrewer)
library(plotly)

shinyUI(fluidPage(
  
  # Application title
  titlePanel("Macroeconomic indicators - Europe"),
  
  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
      h3("Menu"),
      selectInput('Indicator', 'Choose economic indicator', choices = c(  "3_month_interest_rate", "HICP", "unemployment", "Production_in_industry", "GDP"), selected = "3_month_interest_rate"),      
      uiOutput('checkboxGroupx'), #potrzebujemy odwołać się do input$xcol czego nie moge zrobić wew ui.R
      uiOutput('selectInputx')
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
        p("The app downloads 5 economic indicators directly from Eurostat database and present chosen indicator for selected countries and selected point of time choropleth on the map of Europe.
          The map is interactive. If user point with mouse a country, appear pop up with value of a given indicator and country.
          User may choose macroeconomic indicators such as:\n"),
        p("*  Gross domestic product, current prices - Million EUR - seasonally adjusted.  "),
        p("* Harmonized Indices of Consumer Prices (HICPs) are designed for international comparisons of consumer price inflation. Percentage change m/m-1"),
        p("* Employment by NACE Rev.2 - percentage change Q/Q-1 - %. "),
        p("* 3-month-interest rate - Monthly average - not seasonally adjusted."),
        # p("* Production in industry - total (excluding construction). Index 2010 = 100."),
        plotlyOutput("mapPlot")
        #,
        # tabPanel("Table", tableOutput("table"))
      # plotlyOutput("mapPlot")
      
    )
  )
))
