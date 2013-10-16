library(shiny)

fig.width <- 600
fig.height <- 450

shinyUI(pageWithSidebar(
  
  headerPanel("Uncertainty in Linear Regression"),
  
  sidebarPanel(
    
    div(p("Relate the width of the regression error bars to the distribution of bootstrapped regression lines")),
    
    div(
      
      sliderInput("n.boot",
                  strong("Number of bootstrap lines"),
                  min=0, max=100, step=1, value=0, ticks=FALSE),
      br(),
      checkboxInput("plot.boot.dist",
                    strong("Plot the distribution of yhat"),
                    value=FALSE),
      br(),
      sliderInput("dist.pos",
                  strong("Position of the density"),
                  min=-4, max=4, step=.25, value=0, ticks=FALSE)
      
    )
  ),

  mainPanel(
    div(plotOutput("reg.plot", width=fig.width, height=fig.height))
  )
    
))
