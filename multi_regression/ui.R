library(shiny)

fig.width <- 600
fig.height <- 450

shinyUI(pageWithSidebar(
  
  headerPanel("Modeling choices in multiple regression"),
  
  sidebarPanel(
    
    div(p("Relate modeling choices to plots and summaries of the models")),
    
    div(
      
      selectInput("model",
                  strong("Linear model to evaluate"),
                  choices=c("Simple regression",
                            "Additive model",
                            "Interactive model")),
      br(),
      br(),
      actionButton("resample", "New Sample"),
      br(),
      br(),
      sliderInput("a",
                  strong("True intercept"),
                  min=0, max=2, step=.2, value=1, ticks=FALSE),
      sliderInput("b",
                  strong("True main effect of x"),
                  min=0, max=2, step=.2, value=1, ticks=FALSE),
      sliderInput("c",
                  strong("True main effect of group"),
                  min=0, max=2, step=.2, value=1, ticks=FALSE),
      sliderInput("d",
                  strong("True interaction between x and group"),
                  min=0, max=2, step=.2, value=1, ticks=FALSE),
      sliderInput("e",
                  strong("Error standard deviation"),
                  min=0, max=2, step=.2, value=1, ticks=FALSE)
    )
  ),

  mainPanel(
    div(plotOutput("reg.plot", width=fig.width, height=fig.height)),
    div(class="span7", verbatimTextOutput("reg.summary"))
  )
    
))
