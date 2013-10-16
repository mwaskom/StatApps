library(shiny)

fig.width <- 600
fig.height <- 250
shinyUI(pageWithSidebar(
  headerPanel("Sampling and Standard Error"),
  
  sidebarPanel(
    sliderInput("pop.sd", 
                strong("Population standard deviation"), 
                min=0, max=4, value=2, step=.2, ticks=FALSE),
    sliderInput("n.sample",
                strong("Number of observations in a sample"),
                min=1, max=100, value=20)
  ),

  
  mainPanel(
    div(plotOutput("population", width=fig.width, height=fig.height)),
    div(plotOutput("sample", width=fig.width, height=fig.height)),
    div(plotOutput("standard.error", width=fig.width, height=fig.height))
  )
))