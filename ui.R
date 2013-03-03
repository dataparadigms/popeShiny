# file: ui.R
#
#
# description:
#  sets the user interfact

library(shiny)

# Define UI for miles per gallon application
shinyUI(bootstrapPage(

  headerPanel("Next Pope"),
  
  mainPanel(

    div(class="span12",
      plotOutput("ggplot")),

    div(class="span2",
      sliderInput("rank", 
      "Top N Candidates:",
      min = 1,
      max = 10,
      value = 1))
  )

))


# <div class="navbar navbar-inverse navbar-fixed-top">
#   <div class="navbar-inner">
#     <div class="container">
#       <a class="btn btn-navbar" data-toggle="collapse" data-target=".nav-collapse">
#         <span class="icon-bar"></span>
#         <span class="icon-bar"></span>
#         <span class="icon-bar"></span>
#       </a>
#       <a class="brand" href="index.html">Everlasting Classic</a>
#       <div class="nav-collapse collapse">
#         <ul class="nav">
#           <li class="active"><a href="index.html">Home</a></li>
#           <li><a href="http://everlastingclassic.com/blog/">Blog</a></li>
#         </ul>
#       </div><!--/.nav-collapse -->
#     </div>
#   </div>
# </div>