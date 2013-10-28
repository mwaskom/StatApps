library(shiny)

shinyUI(pageWithSidebar(
  
  headerPanel("Multicollinearity in multiple regression"),
  
  sidebarPanel(
    
    div(p("Explore the effects of multicollinearity on multiple regression results")),
    
    div(
      br(),
      sliderInput("pred.cov",
                  "Predictor covariance",
                  min=0, max=.95, step=.05, value=0, ticks=FALSE),
      br(),
      actionButton("resample", "New Sample")
    )
  ),

  mainPanel(
    div(plotOutput("reg.plots", width=600, height=320)),
    div(plotOutput("coef.plots", width=600, height=320)),
    div(p(strong("Full model summary"))),
    div(class="span7", verbatimTextOutput("reg.summary"))
  )
    
))
