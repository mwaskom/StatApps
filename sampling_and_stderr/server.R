library(shiny)

shinyServer(function(input, output) {
  
  output$population <- renderPlot({
    x <- seq(-10, 10, length.out=1000)
    pdf <- dnorm(x, 0, input$pop.sd)
    plot(x, pdf, type="l", col="navy", lwd=3, main="Population", frame=FALSE)
  })
  
  output$sample <- renderPlot({
    x <- rnorm(input$n.sample, 0, input$pop.sd)
    x <- x[x > -10 & x < 10]
    bins <- hist(x, breaks=seq(-10, 10, 1), col="#BBBBBB", xlim=c(-10, 10),
                 main="One Sample from the Population")
    annot.height <- max(bins$count) / 2
    sd.x = sd(x)
    sem.x = sd(x) / sqrt(length(x))
    lines(c(-sd.x, sd.x), rep(annot.height, 2), lwd=6, col="darkred")
    lines(c(-sem.x, sem.x), rep(annot.height, 2), lwd=5, col="pink")
    
    legend(-10, max(bins$count), c("+/- sd", "+/- sem"),
           col=c("darkred", "pink"), lty=c(1, 1), lwd=c(4, 4),
           box.lwd = 0, box.col = "white",bg = "white")
    
    rug(x, col="navy", lwd=2, ticksize=.05)
    
  })
  
  output$standard.error <- renderPlot({
    sem <- input$pop.sd / sqrt(input$n.sample)
    x <- rnorm(10000, 0, sem)
    hist(x, col="#BBBBBB", xlim=c(-10, 10), freq=FALSE,
         main="Distribution of Means from Many Samples")
    x.pos <- seq(-10, 10, length.out=1000)
    pdf <- dnorm(x.pos, 0, sem)
    lines(x.pos, pdf, col="navy", lwd=2)
    annot.height <- max(pdf) / 2
    lines(c(-sem, sem), rep(annot.height, 2), lwd=4, col="pink")
    
    legend(-10, max(pdf), "+/- sd",
           col="pink", lty=1, lwd=4,
           box.lwd = 0, box.col = "white",bg = "white")
    
  })
})