# WHO_TB_Burden

1. WHO data for worldwide incidence of Tuberculosis. (2000-2016)

This application is adaped from one received in the first Nairobi Data Science Newsletter on February 4, 2019.

https://gabrielmutua.shinyapps.io/dash/

The code is given in the follwing Github repository.

https://github.com/GabuTheGreat/shinyDashboard

2. The app.R Shiny app can be run by the following commands in Rstudio.

library(shiny)

library(shinydashboard)

library(data.table)

library(ggplot2)

library(plotly)

shiny::runGitHub("WHO_TB_Burden", "damonzon")

3. world.csv is the worldwide ISO data from the following URL:

https://github.com/lukes/ISO-3166-Countries-with-Regional-Codes/blob/master/all/all.csv















