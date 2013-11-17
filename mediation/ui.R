library(shiny)

shinyUI(pageWithSidebar(
  
  headerPanel("Simple mediation structure"),
  
  sidebarPanel(
    
    div(
      p(strong("Choose values to characterize the mediation structure")),
      sliderInput("a.b",
                  "Influence of A on B",
                  min=-1, max=1, step=.05, value=0, ticks=FALSE),
      sliderInput("b.c",
                  "Influence of B on C",
                  min=-1, max=1, step=.05, value=0, ticks=FALSE),
      sliderInput("a.c",
                  "Independent influence of A on C",
                  min=-1, max=1, step=.05, value=0, ticks=FALSE),
      br(),
      br(),
      p(strong("Manipulate A and observe the effects on B and C")),
      sliderInput("a.val",
                  "Strength of A",
                  min=-1, max=1, step=.05, value=0, ticks=FALSE),
      br(),
      br(),
      p(strong("Show summaries from simulated data with this structure")),
      checkboxInput("models",
                    "Simulate the mediation model",
                    value=FALSE),
      br(),
      actionButton("resample", "New Sample")
    )
    
    
  ),
  
  mainPanel(
    div(class="span8", plotOutput("plots", width=600, height=400),
                       conditionalPanel("input.models == true",
                                        p(strong("Direct model")),
                                        verbatimTextOutput("direct.model")),
                       conditionalPanel("input.models == true",
                                        p(strong("Full model")),
                                        verbatimTextOutput("full.model")))
 
  )
))