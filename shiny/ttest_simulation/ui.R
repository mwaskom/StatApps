library(shiny)

fig.width <- 600
fig.height <- 350

shinyUI(pageWithSidebar(
  
  headerPanel("Simulating T-Tests"),
  
  sidebarPanel(
    
    div(p("Simulate 1000 one-sample t tests where H_0 <= 0 while manipulating the effect size and number of samples.")),
    
    div(
      
      sliderInput("effect.size", 
                  strong("Effect size"), 
                  min=0, max=1, value=0, step=.1, ticks=FALSE),
      sliderInput("sample.size",
                  strong("Number of observations in a sample"),
                  min=1, max=50, value=20, step=1, ticks=FALSE)
                
    )
  ),

  mainPanel(
    plotOutput("t.stats", width=fig.width, height=fig.height),
    plotOutput("p.values", width=fig.width, height=fig.height)
  )
    
))