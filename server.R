
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(SmarterPoland)
library(RColorBrewer)
library(plotly)

table<-data.frame(country =
                    c('Belgium',
                      'Bulgaria',
                      'Czech Republic',
                      'Denmark',
                      'Germany',
                      'Estonia',
                      'Ireland',
                      'Greece',
                      'Spain',
                      'France',
                      'Croatia',
                      'Italy',
                      'Cyprus',
                      'Latvia',
                      'Lithuania',
                      'Luxembourg',
                      'Hungary',
                      'Malta',
                      'Netherlands',
                      'Austria',
                      'Poland',
                      'Portugal',
                      'Romania',
                      'Slovenia',
                      'Slovakia',
                      'Finland',
                      'Sweden',
                      'United Kingdom'), 
                  abbreviation = c('BE',
                                   'BG',
                                   'CZ',
                                   'DK',
                                   'DE',
                                   'EE',
                                   'IE',
                                   'EL',
                                   'ES',
                                   'FR',
                                   'HR',
                                   'IT',
                                   'CY',
                                   'LV',
                                   'LT',
                                   'LU',
                                   'HU',
                                   'MT',
                                   'NL',
                                   'AT',
                                   'PL',
                                   'PT',
                                   'RO',
                                   'SI',
                                   'SK',
                                   'FI',
                                   'SE',
                                   'UK')
)

tmp_GDP <- getEurostatRaw(kod = "teina010", rowRegExp=NULL, colRegExp=NULL, strip.white = TRUE)
tmp_HICP <- getEurostatRaw(kod = "teicp000", rowRegExp=NULL, colRegExp=NULL, strip.white = TRUE)
tmp_HICP <- tmp_HICP[41:79,]
tmp_unemployment <- getEurostatRaw(kod = "teina310", rowRegExp=NULL, colRegExp=NULL, strip.white = TRUE)
tmp_unemployment <- tmp_unemployment [254:276,]
tmp_3_month_interest_rate <- getEurostatRaw(kod = "teimf040", rowRegExp=NULL, colRegExp=NULL, strip.white = TRUE)
tmp_Production_in_industry <- getEurostatRaw(kod = "teiis080", rowRegExp=NULL, colRegExp=NULL, strip.white = TRUE)
tmp_Production_in_industry <-tmp_Production_in_industry[1:36,]
shinyServer(function(input, output) {

  output$checkboxGroupx <- renderUI({
    indicator <- input$Indicator

    tmp_data <- eval(parse(text=paste0("tmp_",indicator)))
    tmp_data <- na.omit(tmp_data)
    country_abbreviations <- function(data){
      wektor <- c()
      for (i in 1:nrow(data)){
        wektor[i] <- substring(data[i,1],nchar(data[i,1])-1, nchar(data[i,1]))
      }
      return(wektor)
    }

    tmp_data$abbreviation <- country_abbreviations(tmp_data)
    tmp_data <- merge(x = table, y = tmp_data, by = "abbreviation", all.y = TRUE)
    colnames(tmp_data) <- paste0("my_",colnames(tmp_data))
    countries <- unique(as.character(tmp_data$my_country[!is.na(tmp_data$my_country)]))
    checkboxGroupInput(inputId = 'Countries', label = 'Choose countries', choices = countries, selected = countries)
  })
    
  output$selectInputx <- renderUI({
    indicator <- input$Indicator
    
    tmp_data <- eval(parse(text=paste0("tmp_",indicator)))
    tmp_data <- na.omit(tmp_data)
    
    colnames(tmp_data) <- paste0("my_",colnames(tmp_data))
    
    time <- c()
    for (i in 1 : ncol(tmp_data)){
      time[i] <- substr(colnames(tmp_data)[i] , 4, nchar(colnames(tmp_data)[i] ))
    }
    time <- time[-1] ### !!!!!!  tu sprawdź czy dobry kolumny obcinasz!!! ###
    
    selectInput('Time', 'Choose point of time', choices = time)
  })
    
  
  
  output$mapPlot <- renderPlotly({
    
    indicator <- input$Indicator
    countries <- input$Countries
    tmp_data <- eval(parse(text=paste0("tmp_",indicator)))
    tmp_data <- na.omit(tmp_data)
    country_abbreviations <- function(data){
      wektor <- c()
      for (i in 1:nrow(data)){
        wektor[i] <- substring(data[i,1],nchar(data[i,1])-1, nchar(data[i,1]))
      }
      return(wektor)
    }
    
    tmp_data$abbreviation <- country_abbreviations(tmp_data)
    tmp_data <- merge(x = table, y = tmp_data, by = "abbreviation", all.y = TRUE)
    tmp_data <- na.omit(tmp_data)
    colnames(tmp_data) <- paste0("my_",colnames(tmp_data))
    tmp_data =  tmp_data[tmp_data$my_country %in% countries,]    
    
    state_codes = as.character(tmp_data$my_country[!is.na(tmp_data$my_country)])
    value = eval(parse(text=paste0("tmp_data$my_",input$Time)))
    #pop =  tmp_GDP$my_2012Q4[!is.na(tmp_GDP$my_country)]
    df_states = data.frame(state_codes, value)
    
    g <- list(
      scope = "europe",
      showframe = FALSE,
      showcoastlines = FALSE,
      projection = list(type = 'Mercator')
    )
    
    plot_ly(df_states, z=value, locations=state_codes,  text=paste0(df_states$state_codes, '<br>', indicator, ': ', df_states$value) ,
            type="choropleth", locationmode = 'country names', colors = 'Purples', filename="stackoverflow/simple-choropleth") %>%
      layout(title = 'Eurostat - GDP',
             geo = g)
    
#      output$dataset <- renderTable({
#        indicator <- input$Indicator
#        tmp_data <- eval(parse(text=paste0("tmp_",indicator)))
#      })
    
  })

})
