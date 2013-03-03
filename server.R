# file: server.R
#
# description:
#  defines the various server logic needed 

library(shiny)
library(lubridate)
library(ggplot2)
library(scales)
library(RColorBrewer)

# do the nessecary data mungling,  this step will take a bit to initialize
stream <- read.csv("http://www.procrun.com/popeOdds/output.csv",
                   as.is = TRUE,
                   header = FALSE)
colnames(stream) <- c("x", "title", "name", "country", "odds", "y")

# put together a new data frame to export to json
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
ranked$rank <- rank(-ranked$y, ties.method = "min")
ranked <- ranked[with(ranked, order(rank)),]
ranked <- ranked[ranked$rank <= 10, ]

# merge back
condensed <- merge(condensed, ranked[, c(1,4)], by = c("candidate"))
candidateColors <- brewer.pal(12, "Paired")
names(candidateColors) <- levels(factor(condensed$candidate))

shinyServer(function(input, output) {

  # reactive to the slide to pull the the top n ranks
  sliderValues <- reactive({
    temp <- subset(condensed, rank <= input$rank)
  })

  # show the values using an html table

  output$ggplot <- renderPlot({

    # set stable temp df so the max function doesn't force a function recall
    temp <- sliderValues()

    # create the plot
    p <- ggplot(temp, aes(x, y))

    p <- p + geom_line(aes(colour = candidate)) +
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