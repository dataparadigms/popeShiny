# file: server.R
# 
# author: AJ
# twitter: dataparadigms
# web: http://www.dataparadigms.com
#
# description:
#  defines the various server logic needed 

library(shiny)
library(lubridate)
library(ggplot2)
library(scales)
library(RColorBrewer)

loadData <- function(){
  # loads the most recent odds, on load and then when user chooses to. 
  #
  # returns:
  #   munged data.frame needed for the server

  # temporary server for data file to prevent overflow on static site

  stream <- read.csv("http://www.procrun.com/popeOdds/output.csv",
                   as.is = TRUE,
                   header = FALSE)
  colnames(stream) <- c("x", "title", "name", "country", "odds", "y")

  # put together a new data frame
  condensed <- data.frame(candidate = paste(stream$title, 
                                            stream$name, 
                                            paste("(", stream$country, ")", sep="")),
                          x = parse_date_time(stream$x, '%Y%m%d%H%M%S'), 
                          y = stream$y)

  # check for any duplicates
  condensed <- condensed[!duplicated(condensed), ]

  # order
  condensed <- condensed[with(condensed, order(candidate, x)),]

  # rank for the max time
  ranked <- condensed[as.double(condensed$x) == as.double(max(condensed$x)), ]
  ranked$rank <- rank(-ranked$y, ties.method = "max")
  ranked <- ranked[with(ranked, order(rank)),]
  ranked <- ranked[ranked$rank <= 1, ]

  # on the day the conclave concludes,  should show convergence to Pope by elected and 
  # the decline on the odds for the front runners over time.
  if (nrow(ranked) <= 1) {

    rankedInitial <- condensed[as.double(condensed$x) == as.double(min(condensed$x)), ]
    rankedInitial <- rankedInitial[!(rankedInitial$candidate %in% unique(ranked$candidate)), ]
    rankedInitial$rank <- rank(-rankedInitial$y, ties.method = "max")
    rankedInitial$rank <- rankedInitial$rank + 1
    rankedInitial <- rankedInitial[with(rankedInitial, order(rank)),]
    rankedInitial <- rankedInitial[rankedInitial$rank <= 15, ]
    ranked <- rbind(ranked, rankedInitial)
  }
  
  # merge back
  condensed <- merge(condensed, ranked[, c(1,4)], by = c("candidate"))
  return(condensed)
}

setColors <- function(df){
  # sets consistent colors for the plot based on the data
  #
  # args:
  #   df: data.frame with a list of candidates and no more than 12 for
  #       for unique color assignment
  #
  # returns:
  #   vector of colors and corresponding name

  colors <- c(brewer.pal(12, "Set3"), brewer.pal(10, "RdBu"))
  names(colors) <- levels(factor(df$candidate))
  return(colors)
}


# sets up based on the data when the server was loaded
options <- loadData()
candidateColors <- setColors(options)

# needed for the shiny server to run
shinyServer(function(input, output) {

  # reactive to the slide to pull the the top n ranks
  sliderValues <- reactive({    
    temp <- subset(options, rank <= input$rank)
  })

  # render plot to pass the ggplot back to the ui.R
  output$ggplot <- renderPlot({
    # set stable temp df so the max function doesn't force a function recall
    temp <- sliderValues()

    # create the plot
    p <- ggplot(temp, aes(x, y))

    p <- p + geom_line(aes(colour = candidate), size = 1.25) +
          theme_bw() +
          scale_y_continuous(breaks = seq(0,1,.05)) +
          scale_color_manual(name = "candidate", values = candidateColors) + 
          labs(title = 'Probability of Being the Next Pope',
               x = '',
               y = '') +
          theme(legend.title = element_blank(),
                legend.position = 'right',
                legend.key = element_blank(),
                plot.title = element_text(face = 'bold'))
    plot(p)
  })

})
