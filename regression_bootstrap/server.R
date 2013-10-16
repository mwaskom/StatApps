library(shiny)

shinyServer(function(input, output) {

  # --------------------------------------------------------------------------
  # Get a set of random data with a fixed true model
  make.regression <- reactive({
    # This gets called whenever the app is reloaded
    
    # Set up the true model
    n.obs = 30
    x <- rnorm(n.obs, 0, 2)
    x.out <- abs(x) > 3
    while (any(x.out)){
      x[x.out] <- rnorm(sum(x.out), 0, 2)
      x.out <- abs(x) > 3
    }
    
    y <- 2 + .75 * x + rnorm(n.obs, 0, 1)
    model.fit <- lm(y ~ x)
    fit.coef <- model.fit$coefficients
    
    # Bootstrap the regression
    boot.coef <- matrix(NA, nrow=100, ncol=2)
    for (i in 1:100){
      boot.idx <- sample(seq(1, n.obs), replace=TRUE)
      x.boot <- x[boot.idx]
      y.boot <- y[boot.idx]
      fit.boot <- lm(y.boot ~ x.boot)
      boot.coef[i,] <- fit.boot$coefficients
    }
      
    return(list(x=x, y=y, model.fit=model.fit,
                fit.coef=fit.coef, boot.coef=boot.coef))
    
  })  
  
    
  #---------------------------------------------------------------------------
  # Plot a scatter of the data and the current model with residuals
  output$reg.plot <- renderPlot({         
  
    # Get the current regression data
    reg.data <- make.regression()
    x <- reg.data$x
    y <- reg.data$y
    fit.coef <- reg.data$fit.coef
    
    # Plot the true model
    plot(x, y, xlim=c(-4, 4), ylim=c(-2, 5), pch=16, cex=1.2, col="#333333", bty="n")
    abline(coef=fit.coef, lwd=3.5)
    
    # Find the standard error of the regression
    model.fit <- reg.data$model.fit
    x.vals <- seq(-4.5, 4.5, .01)
    y.vals <- fit.coef[1] + fit.coef[2] * x.vals
    se <- predict(model.fit, data.frame(x=x.vals), se.fit=TRUE)$se.fit
    
    # Find the parameters for the negative density
    dist.pos <- input$dist.pos
    se.loc <- predict(model.fit, data.frame(x=dist.pos), se.fit=TRUE)$se.fit
    y.hat.loc <- fit.coef[1] + fit.coef[2] * dist.pos
    y.loc <- seq(qnorm(.0001, y.hat.loc, se.loc),
                 qnorm(.9999, y.hat.loc, se.loc), .01)
    d.se <- dnorm(y.loc, y.hat.loc, se.loc)

    # Plot the bootstrap estimates
    boot.coef <- reg.data$boot.coef
    if (input$n.boot > 0){
      for (n in 1:input$n.boot){
        abline(coef=boot.coef[n,], col=rgb(1, .5, 0, .33))
      }
    }
    
    # Plot the standard error of the regression
    lines(x.vals, y.vals + se, col="steelblue", lwd=2)
    lines(x.vals, y.vals - se, col="steelblue", lwd=2)
    
    # Plot the bootstrap distribution curve
    if (input$plot.boot.dist){
      abline(v=dist.pos, lty=3)
      lines(dist.pos + d.se, y.loc, col="#333333", lwd=2)
    }
    
  })
  
})