library(shiny)
library(RColorBrewer)

shinyServer(function(input, output) {
  
  # --------------------------------------------------------------------------
  # Make x values and some normally distributed random noise
  random.sample <- reactive({
    
    # Dummy line to trigger off button-press
    foo <- input$resample
    n.obs <- 60
    x <- runif(n.obs, 0, 2)
    noise <- rnorm(n.obs) 
    color <- sample(brewer.pal(9, "Set1")[-6], 1)
    return(list(x=x, noise=noise, color=color))
      
  })
    
  # --------------------------------------------------------------------------
  # Set up the dataset based on the inputs 
  make.regression <- reactive({
    
    sample <- random.sample()
    
    # Set up the true model
    n.obs <- 60
    x.0 <- rep(1, n.obs)
    x.1 <- sample$x
    x.2 <- rep(c(0, 1), n.obs / 2)
    x.3 <- x.1 * x.2
    X <- matrix(c(x.0, x.1, x.2, x.3), ncol=4)
    b <- matrix(c(input$a, input$b, input$c, input$d))
    y <- X %*% b + sample$noise * input$e
    colnames(X) <- c("intercept", "x", "group", "interaction")
    df <- as.data.frame(X)
    df$y <- y
    
    return(list(df=df, X=X, y=y))    
    
  })  
  
  # --------------------------------------------------------------------------
  # Fit the specified regression model
  fit.regression <- reactive({
    
    # Get the current model structure
    data <- make.regression()
    df <- data$df
    
    # Conditionally fit the model
    if (input$model == "Simple regression") {
      fit.res <- lm(y ~ x, df)
    } else if (input$model == "Additive model") {
      fit.res <- lm(y ~ x + group, df)
    } else if (input$model == "Interactive model") {
      fit.res <- lm(y ~ x * group, df)
    } else {
      fit.res <- NULL
    }
    
    # Get the model summary
    if (is.null(fit.res)) {
      fit.summary <- NULL
    } else {
      fit.summary <- summary(fit.res)
    }
  
    return(list(fit.res=fit.res, fit.summary=fit.summary))
    
  })
    
  #---------------------------------------------------------------------------
  # Plot a scatter of the data with regression lines corresponding to the model
  output$reg.plot <- renderPlot({         
  
    # Get the current regression data
    data <- make.regression()
    x <- data$df$x
    y <- data$df$y
    g <- data$df$group
    coefs <- fit.regression()$fit.res$coefficients
    
    # Plot the true model
    other.color <- random.sample()$color
    plot(x[g == 0], y[g == 0], xlim=c(0, 2), ylim=c(-1, 8),
         pch=16, cex=1.2, col="#333333", bty="n", xlab="x", ylab="y")
    points(x[g == 1], y[g == 1], pch=16, cex=1.2, col=other.color)
    
    if (input$model == "Simple regression") {
      abline(coefs["(Intercept)"], coefs["x"], col="#333333", lwd=3)
    } else if (input$model == "Additive model") {
      abline(coefs["(Intercept)"], coefs["x"], col="#333333", lwd=3)
      abline(coefs["(Intercept)"] + coefs["group"], coefs["x"], col=other.color, lwd=3)
    } else if (input$model == "Interactive model") {
      abline(coefs["(Intercept)"], coefs["x"], col="#333333", lwd=3)
      abline(coefs["(Intercept)"] + coefs["group"],
             coefs["x"] + coefs["x:group"], col=other.color, lwd=3)
    }
    
  })
  
  #---------------------------------------------------------------------------
  # Show the lm() summary for the 
  output$reg.summary <- renderPrint({
    
    summary <- fit.regression()$fit.summary
    if (!is.null(summary)) {
      return(fit.regression()$fit.summary)
    }
    
  })
  
})