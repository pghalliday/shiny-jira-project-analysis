library(tm)
library(wordcloud)
library(memoise)

# The list of valid books
books <<- list("A Mid Summer Night's Dream" = "summer",
              "The Merchant of Venice" = "merchant",
              "Romeo and Juliet" = "romeo")

# Using "memoise" to automatically cache the results
get_term_matrix <- memoise(function(book) {
  # Careful not to let just any name slip in here; a
  # malicious user could manipulate this value.
  if (! (book %in% books))
    stop("Unknown book")

  text <- readLines(
    sprintf("./%s.txt.gz", book),
    encoding = "UTF-8"
  )

  mycorpus <- Corpus(VectorSource(text))
  mycorpus <- tm_map(mycorpus, content_transformer(tolower))
  mycorpus <- tm_map(mycorpus, removePunctuation)
  mycorpus <- tm_map(mycorpus, removeNumbers)
  mycorpus <- tm_map(mycorpus, removeWords,
         c(stopwords("SMART"), "thy", "thou", "thee", "the", "and", "but"))

  mydtm <- TermDocumentMatrix(mycorpus,
              control = list(minWordLength = 1))
  
  m <- as.matrix(mydtm)
  
  sort(rowSums(m), decreasing = TRUE)
})
