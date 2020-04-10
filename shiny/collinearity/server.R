library(shiny)
library(MASS)

shinyServer(function(input, output) {
  
  # --------------------------------------------------------------------------
  # Simulate the dataset with correlated regressors
  random.sample <- reactive({
    
    # Dummy line to trigger off button-press
    foo <- input$resample
    n.obs <- 60
    cov <- input$pred.cov
    sigma <- matrix(c(1, cov, cov, 1), nrow=2)
    X <- mvrnorm(n.obs, c(0, 0), sigma)
    b <- c(1, 1)
    y <- X %*% b + rnorm(n.obs, sd=1.5)
    df <- cbind(y, X)
    df <- as.data.frame(df)
    names(df) <- c("y", "x.1", "x.2")
    
    return(df)
      
  })
    
  # --------------------------------------------------------------------------
  # Fit the the full and nested regression models
  fit.regressions <- reactive({
    
    # Get the current model structure
    df <- random.sample()
    
    reg.full <- lm(y ~ x.1 + x.2, df)
    reg.x.1 <- lm(y ~ x.1, df)
    reg.x.2 <- lm(y ~ x.2, df)
    
    return(list(reg.full=reg.full, reg.x.1=reg.x.1, reg.x.2=reg.x.2))
    
  })
    
  #---------------------------------------------------------------------------
  # Plot a scatter of the data with regression lines corresponding to the model
  output$reg.plots <- renderPlot({         
  
    # Get the current regression data
    df <- random.sample()
    reg.full <- fit.regressions()$reg.full
    y.hat <- predict(reg.full)
    
    # Set up the plots
    par(mfrow=c(1, 2))
    #colors = sample(brewer.pal(8, "Set2"), 2, FALSE)
    colors = c("#66C2A5", "#80B1D3")
    
    # Plot y on yhat
    plot(y.hat, df$y, type="p", main="Overall model fit",
         xlab="y hat", ylab="y", col=colors[1], pch=16,
         bty="n", xlim=c(-6, 6), ylim=c(-6, 6))
    abline(0, 1, lty="dotted")

    # Plot x.2 on x.2
    plot(df$x.1, df$x.2, type="p", main="Predictor variable correlation",
         xlab="x.1", ylab="x.2", col=colors[2], pch=16,
         bty="n", xlim=c(-3, 3), ylim=c(-3, 3))
    abline(0, 1, lty="dotted")
    
  })
  
  #---------------------------------------------------------------------------
  # Plot the model coefficients and standard errors
  output$coef.plots <- renderPlot({         
  
    # Get the current regression data
    reg.list <- fit.regressions()
    
    # Get more info about the regessions
    reg.full <- summary(reg.list$reg.full)
    reg.x.1 <- summary(reg.list$reg.x.1)
    reg.x.2 <- summary(reg.list$reg.x.2)
    
    # Set up the x positions
    x.pos <- c(1, 2, 4, 5)
    x.names <- rep(c("x.1", "x.2"), 2)
    #c.idx <- sample(1:5, 2, FALSE)
    #c.idx <- c.idx * 2
    #pal <- brewer.pal(10, "Paired")
    #colors <- c(pal[c.idx], pal[c.idx - 1])
    colors <- rep(c("#343434", "#767676"), 2)
    
    # Plot the point estimates of the coefficients
    full.coefs <- reg.full$coefficients[c("x.1", "x.2"), "Estimate"]
    x.1.coef <- reg.x.1$coefficients["x.1", "Estimate"]
    x.2.coef <- reg.x.2$coefficients["x.2", "Estimate"]
    coefs <- c(full.coefs, x.1.coef, x.2.coef)
    
    plot(x.pos, coefs, type="p", pch=16, xlab="", ylab="", cex=1.5,
         xlim=c(0, 6), ylim=c(-1.3, 3.3), bty="n", xaxt="n", col=colors)
    abline(h=0, lty="dashed")
    
    text(1.5, 3.1, "Coefficients in full model")
    text(4.5, 3.1, "Coefficients in separate models")
    
    # Plot the standard errors
    full.ses <- reg.full$coefficients[c("x.1", "x.2"), "Std. Error"]
    x.1.se <- reg.x.1$coefficients["x.1", "Std. Error"]
    x.2.se <- reg.x.2$coefficients["x.2", "Std. Error"]
    ses <- c(full.ses, x.1.se, x.2.se)
    for (col in 1:4) {
      x <- x.pos[col]
      coef <- coefs[col]
      ci <- 1.96 * ses[col]
      lines(c(x, x), c(coef - ci, coef + ci), lwd=4, col=colors[col])
      text(x, -1.15, x.names[col])
    }
    
  })
  
  #---------------------------------------------------------------------------
  # Show the lm() summary for the 
  output$reg.summary <- renderPrint({
    
    return(summary(fit.regressions()$reg.full))
    
  })
  
})