
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(ggplot2)
library(stringr)
library(psych)
library(plyr)
library(DT)

n = 5000

shinyServer(function(input, output) {
  
  reac_d = reactive({
    set.seed(74) #for reproducible results
    
    #encapsulate the data generation in {} to make them reproducible
    {
    A = data.frame(S_score = rnorm(n, input$S_adv),
                  T_score = rnorm(n, input$T_adv),
                  group = rep("A", n))
    
    B = data.frame(S_score = rnorm(n),
                  T_score = rnorm(n),
                  group = rep("B", n))
    
    d = as.data.frame(rbind(A, B))
    error_size = sqrt(1 - (input$cor_S^2 + input$cor_T^2))
    
    d$Y = d$S_score * input$cor_S + d$T_score * input$cor_T + error_size * rnorm(n * 2)
    }
    
    #rescale Y
    d$Y = d$Y * 100 + 500
    
    #model
    fit = lm(as.formula(input$model), d)
    d$Y_hat = predict(fit)
    
    return(d)
  })

  output$plot <- renderPlot({
    #get reactive data
    d = reac_d()
    
    #plot
    ggplot(d, aes(Y_hat, Y, color = group)) +
      geom_point(alpha = .5) +
      geom_smooth(method = "lm", se = F, linetype = "dashed", size = .7) +
      geom_smooth(aes(color = NULL), method = "lm", se = F, linetype = "dashed", color = "black", size = .7) +
      xlab("Predicted criteria score") +
      ylab("Criteria score") +
      scale_color_manual(values = c("#4646ff", "#ff4646"), #, #change colors
                         name = "Group", #change legend title
                         labels = c("Blue", "Red")) #change labels 
  
  })
  
  output$table = DT::renderDataTable({
    #fetch data
    d = reac_d()
    
    #desc. stats
    desc = ddply(d, .(group), summarize,
                 mean_S = mean(S_score),
                 mean_T = mean(T_score),
                 mean_Y = mean(Y),
                 mean_Y_hat = mean(Y_hat))

    #table
    d2 = matrix(nrow = 4, ncol = 3)
    #S
    d2[1, 1] = desc[1, "mean_S"]
    d2[1, 2] = desc[2, "mean_S"]
    d2[1, 3] = desc[1, "mean_S"] - desc[2, "mean_S"]
    #T
    d2[2, 1] = desc[1, "mean_T"]
    d2[2, 2] = desc[2, "mean_T"]
    d2[2, 3] = desc[1, "mean_T"] - desc[2, "mean_S"]
    #Y
    d2[3, 1] = desc[1, "mean_Y"]
    d2[3, 2] = desc[2, "mean_Y"]
    d2[3, 3] = desc[1, "mean_Y"] - desc[2, "mean_Y"]
    #Y
    d2[4, 1] = desc[1, "mean_Y_hat"]
    d2[4, 2] = desc[2, "mean_Y_hat"]
    d2[4, 3] = desc[1, "mean_Y_hat"] - desc[2, "mean_Y_hat"]
    
    d2 = round(d2, 2)
    rownames(d2) = c("Trait S", "Trait T", "Criteria score", "Predicted criteria score")
    colnames(d2) = c("Blue group", "Red group", "Blue group's advantage")
    
    DT::datatable(d2, , options = list(searching = F,
                                       ordering = F,
                                       paging = F,
                                       info = F))
  })

})

