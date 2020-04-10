library(shiny)

fig.width <- 600
fig.height <- 450

shinyUI(pageWithSidebar(
  
  headerPanel("Simple Logistic Regression"),
  
  sidebarPanel(
    
    div(p("Try to find values for the slope and intercept that maximize the likelihood of the data.")),
    div(
      
      sliderInput("intercept",
                  strong("Intercept"),
                  min=-3, max=3, step=.25,
                  value=sample(seq(-3, 3, .25), 1), ticks=FALSE),
      br(),
      sliderInput("slope", 
                  strong("Slope"),
                  min=-3, max=3, step=.25, 
                  value=sample(seq(-2, 2, .25), 1), ticks=FALSE),
      br(),
      checkboxInput("logit",
                    strong("Plot in logit domain"),
                    value=FALSE),
      br(),
      checkboxInput("summary",
                    strong("Show summary(glm(y ~ x))"),
                    value=FALSE)
      
    )
  ),

  mainPanel(
    plotOutput("reg.plot", width=fig.width, height=fig.height),
    plotOutput("like.plot", width=fig.width, height=fig.height / 3),
    div(class="span7", conditionalPanel("input.summary == true",
                                        p(strong("GLM Summary")),
                                        verbatimTextOutput("summary")))
  )
    
))