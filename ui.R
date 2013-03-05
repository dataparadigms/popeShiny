# file: ui.R
# 
# author: AJ
# twitter: dataparadigms
# web: http://www.dataparadigms.com
#
# description:
#  sets the user interface

library(shiny)

# define the UI set up, bootstrapPage lets the span for the graph be 12 instead
# of the default 8 with pageWithSidebar
shinyUI(bootstrapPage(

  headerPanel("Next Pope"),
  
  mainPanel(

    div(class="span12",
      plotOutput("ggplot")
    ),

    div(class="span2",
      sliderInput("rank", 
      "Top N Candidates:",
      min = 1,
      max = 15,
      value = 1)
    )
  )

))
