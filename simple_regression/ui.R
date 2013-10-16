library(shiny)

fig.width <- 600
fig.height <- 450

shinyUI(pageWithSidebar(
  
  headerPanel("Simple Linear Regression"),
  
  sidebarPanel(
    
    div(p("Try to find values for the slope and intercept that minimize the residual error from the linear model.")),
    
    div(
      
      sliderInput("intercept",
                  strong("Intercept"),
                  min=-2, max=6, step=.5,
                  value=sample(seq(-2, 6, .5), 1), ticks=FALSE),
      br(),
      sliderInput("slope", 
                  strong("Slope"),
                  min=-1, max=3, step=.25, 
                  value=sample(seq(-1, 3, .25), 1), ticks=FALSE),
      br(),
      checkboxInput("summary",
                    strong("Show summary(lm(y ~ x))"),
                    value=FALSE)
      
    )
  ),

  mainPanel(
    div(plotOutput("reg.plot", width=fig.width, height=fig.height),
        title="y = 2 + x"),
    div(plotOutput("ss.plot", width=fig.width, height=fig.height / 3)),
    div(plotOutput("resid.plot", width=fig.width, height=fig.height / 2)),
    div(class="span7", conditionalPanel("input.summary == true",
                                        p(strong("Linear model summary")),
                                        verbatimTextOutput("summary")))
  )
    
))