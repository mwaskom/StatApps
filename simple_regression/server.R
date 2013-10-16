library(shiny)

shinyServer(function(input, output) {

  # --------------------------------------------------------------------------
  # Get a set of random data with a fixed true model
  draw.sample <- reactive({
    # This gets called whenever the app is reloaded
    
    # Hardcode the true relationship
    n.obs = 50
    x <- rnorm(n.obs, 0, 2)
    y <- 2 + x + rnorm(n.obs, 0, 1)
    
    model.summary <- summary(lm(y ~ x))
    
    return(list(x=x, y=y, model.summary=model.summary))
    
  })  
  
  # --------------------------------------------------------------------------
  # Calculate the current values of the model given the inputs
  regression <- reactive({
    
    # Get shorthand access to the attributes we care about
    data.vals <- draw.sample()
    x <- data.vals$x
    y <- data.vals$y
    a <- input$intercept
    b <- input$slope
    
    # Give a visual cue when we have the right regression
    if (a == 2 & b == 1) resid.color <- "seagreen" else resid.color <- "firebrick"
    
    # Calculate the current residuals
    yhat <- input$intercept + x * input$slope
    resid <- y - yhat
    
    # Calculate the current and optimal residual sum squares
    ss.res <- sum(resid ** 2)
    resid.best <- y - (2 + x)
    ss.res.best <- sum(resid.best ** 2)
    
    # Compute R^2
    r2 <- 1 - (ss.res / sum((y - mean(y)) ** 2))
    
    return(list(x=x, y=y, yhat=yhat, a=a, b=b, r2=r2,
                resid=resid, ss.res=ss.res, ss.res.best=ss.res.best,
                resid.color=resid.color))
    
  })
    
  #---------------------------------------------------------------------------
  # Plot a scatter of the data and the current model with residuals
  output$reg.plot <- renderPlot({         
  
    # Get the current regression data
    reg.data <- regression()
    a <- reg.data$a
    b <- reg.data$b
    x <- reg.data$x
    y <- reg.data$y
    r2 <- reg.data$r2
    resid <- reg.data$resid
    
    # Mask data outside the viewport
    mask <- x > -4.5 & x < 4.5 & y > -3 & y < 8
    x <- x[mask]
    y <- y[mask]
    resid <- resid[mask]
    
    
    # Plot the regression line
    plot(c(-4.5, 4.5), c(a + b * -4.5,  a + b * 4.5), type="l", lwd=2,
         bty="n", xlim=c(-5, 5), ylim=c(-3, 8), xlab="x", ylab="y",
         main="Linear Model Y ~ X")
    
    # Plot each residual distance
    for (i in 1:length(resid)){
      lines(c(x[i], x[i]), c(y[i], y[i] - resid[i]),
            col=reg.data$resid.color, lwd=1.5)
    }
    
    # Plot the observations
    points(x, y,  pch=16, col="#444444")
    
    # Plot the current equation as a legend
    legend(-5, 8, sprintf("y = %.3g + %.3g * x", a, b), lty=1, lwd=2, bty="n")
    
  })
  
  #---------------------------------------------------------------------------
  # Plot the current sum squares along with the minumum possible
  output$ss.plot <- renderPlot({
    
    # Get the current regression data
    reg.data <- regression()
    ss.res <- reg.data$ss.res
    ss.res.best <- reg.data$ss.res.best
    resid.color <- reg.data$resid.color
    
    # Plot the two points
    plot(ss.res, 1, col=resid.color, cex=2,
         yaxt="n", bty="n", xlim=c(0, 1000),
         ylab="", xlab="", main="Sum of Squares of Residuals")
    points(ss.res.best, 1, pch=4, cex=2)
    
  })
  
  #----------------------------------------------------------------------------
  # Plot the current distribution of residuals and the theoretical distribution
  output$resid.plot <- renderPlot({
    
    # Get the current regression data
    reg.data <- regression()
    resid <- reg.data$resid
    resid <- resid[resid > -5 & resid < 5]
    
    # Plot a histogram of the residuals
    hist(resid, seq(-5, 5, .5), prob=TRUE, col="#bbbbbb",
         xlim=c(-5, 5), ylim=c(0, dnorm(0) * 1.5),
         yaxt="n", bty="n", ylab="", xlab="", main="Distribution of Residuals")
    rug(resid, lwd=2)
    
    # Plot a normal density (the expected residual distribtuion)
    curve(dnorm, col=reg.data$resid.color, lwd=2, add=TRUE)
    
  })
  
  #---------------------------------------------------------------------------
  # Print the glm() summary of the true model
  output$summary <- renderPrint({
    
    if (input$summary){
      return(draw.sample()$model.summary)
    }
    
  })
})