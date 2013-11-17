library(shiny)
library(RColorBrewer)

shinyServer(function(input, output) {
  
  #-----------------------------------------------------------------------
  # Define the strength of each link in the path
  structure <- reactive({
    
    b <- input$a.val * input$a.b
    c <- b * input$b.c + input$a.val * input$a.c
    
    return(list(a=input$a.val, b=b, c=c))
    
  })
  
  #----------------------------------------------------------------------
  # Plot the actual values of A, B, and C given the structure and A value
  output$plots <- renderPlot({
    
    # Get the current model structure
    s <- structure()
    
    # Initialize the plot
    plot.new()
    
    # Plot the variable names with size as a function of "activation"
    size <- function(x) { 2 + x * 1.5 }
    text(.1, .155, "A", cex=size(s$a))
    text(.5, .9, "B", cex=size(s$b))
    text(.9, .155, "C", cex=size(s$c))
    
    # Plot the arrows with weight and color as a function of strength
    pal <- brewer.pal(11, "RdYlGn")
    weight <- function (x) { max(.1, 1 + abs(x) * 4) }
    color <- function (y) { pal[max(1, round((y + 1) / 2 * 11))] }
    arrows(.14, .20, .46, .83, col=color(input$a.b), lwd=weight(input$a.b))
    arrows(.54, .83, .855, .26, col=color(input$b.c), lwd=weight(input$b.c))
    arrows(.18, .15, .82, .15, col=color(input$a.c), lwd=weight(input$a.c))
    
  })
  
  #----------------------------------------------------------------------
  # Source the noise separately with a reference to the resample button
  sample.model <- reactive({
    
    # Dummy line
    foo <- input$resample
    direct <- rnorm(30)
    full <- rnorm(30)
    A <- rnorm(30)
    return(list(A=A, direct.noise=direct, full.noise=full))
    
  })
  
  #----------------------------------------------------------------------
  # Simulate and fit the two component models
  make.model <- reactive({
    
    sample <- sample.model()
    
    A <- sample$A
    B <- A * input$a.b + sample$direct.noise
    C <- B * input$b.c + A * input$a.c + sample$full.noise
    
    return(list(A=A, B=B, C=C))
    
  })
  
  #----------------------------------------------------------------------
  # Print the direct model
  output$direct.model <- renderPrint({
    
    m <- make.model()
    A <- m$A
    C <- m$C
    return(summary(lm(C ~ A)))
    
  })
    
  #----------------------------------------------------------------------
  # Print the full model
  output$full.model <- renderPrint({
    
    m <- make.model()
    A <- m$A
    B <- m$B
    C <- m$C
    return(summary(lm(C ~ A + B)))
    
  })
    
})