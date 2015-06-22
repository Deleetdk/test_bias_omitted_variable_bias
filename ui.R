
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

shinyUI(fluidPage(

  # Application title
  titlePanel("Test bias and ommitted variable bias"),

  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
      radioButtons("model",
                   "Which traits are measured by the test?",
                   c("S" = "Y ~ S_score",
                     "T" = "Y ~ T_score",
                     "S and T" = "Y ~ S_score + T_score"),
                   "Y ~ S_score"),
      
      sliderInput("cor_S",
                  "Correlation of trait S with performance on the criteria trait",
                  min = 0,
                  max = .7,
                  value = .5,
                  step = .01),
      
      sliderInput("cor_T",
                  "Correlation of trait T with performance on the criteria trait",
                  min = 0,
                  max = .7,
                  value = .5,
                  step = .01),
      
      sliderInput("S_adv",
                  "The blue group's advantage on trait S",
                  min = -3,
                  max = 3,
                  value = 0,
                  step = .05),
      
      sliderInput("T_adv",
                  "The blue group's advantage on trait T",
                  min = -3,
                  max = 3,
                  value = .5,
                  step = .05)
    ),

    # Show a plot of the generated distribution
    mainPanel(
      HTML("<p>In <a HREF='http://emilkirkegaard.dk/understanding_statistics/?app=test_bias'>the previous visualization</a>, we looked at intercept and slope bias. In this visualization we will look at one way intercept bias can happen without the test being biased, but because another important variable is not included in the prediction model.</p>",
           "<p>In the figure below we see the predicted scores and the actual scores of some persons on a criteria variable. This could be some kind of scholastic test. The predicted scores come from a model based on test scores from a test that measures either the trait S, the trait T or both depending on which setting is chosen in the settings to the left. We can think of S as study habits and T as cognitive ability, but they could be any traits. The criteria score is in fact a function of both traits plus some noise. You can control how important the two traits are for the criteria score in the settings.</p>",
           "<p>In the default setup we see that the test measures only trait S. In the figure we see that there is intercept bias in favor of the blue group -- the blue line is parallel to but above the red line. The black line is the common regression line. We also see in the table below that the blue group actually does better on the criteria. The intercept bias is in fact because the blue group is on average higher on the trait T but that this trait is not measured by the test. Try switching to measuring T or both S and T, and you will see that the bias disappears. This is omitted variable bias.</p>",
           "<p>In the case before, the blue group's performance on the criteria test was in fact better than the red group's, but this need not be so. Try setting the blue group's advantage on trait S to -1. Now the red group has an advantage on trait S while the blue group has an advantage on test T. As a result, both groups do equally well on the criteria. Notice how using either S and T alone as a predictor results in intercept bias in two different directions, but using both together removes the bias.</p>",
           "<p>Omitted variable bias in fact can happen in real life. It can happen when some outcome is determined by multiple traits -- which is most of the time -- and two groups differ on some but not all of these traits and not all the traits are included in the prediction models, see <a HREF='http://emilkirkegaard.dk/en/wp-content/uploads/Differential-Prediction-and-the-Use-of-Multiple-Predictors.pdf'>Sackett et al (2003)</a>.</p>"),
      plotOutput("plot"),
      DT::dataTableOutput("table"),
      HTML("Made by <a href='http://emilkirkegaard.dk'>Emil O. W. Kirkegaard</a> using <a href='http://shiny.rstudio.com/'/>Shiny</a> for <a href='http://en.wikipedia.org/wiki/R_%28programming_language%29'>R</a>. Source code available on <a href='https://github.com/Deleetdk/test_bias_omitted_variable_bias'>Github</a>.")
    )
  )
))
