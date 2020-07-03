# Stroke Comorbidity Searches in MedRxiv
# 03 June 2020
# ABB
### Amended code for biorXiv kkindly provided by Luke McGuiness - author of "mcguinlu/medrxivr" R package.

# load required packages
library(dplyr)
library(medrxivr)

# Create bx_api_content
# Modified version of mx_api_content()
bx_api_content <- function(from.date = "2013-01-01",
                           to.date = Sys.Date(),
                           clean = TRUE,
                           include.info = FALSE) {
  
  # Create baseline link
  base_link <- paste0("https://api.biorxiv.org/details/biorxiv/",
                      from.date,
                      "/",
                      to.date)
  
  details <-
    httr::RETRY(
      verb = "GET",
      times = 3,
      url = paste0(base_link, "/0"),
      httr::timeout(30)
    ) %>%
    httr::content(as = "text", encoding = "UTF-8") %>%
    jsonlite::fromJSON()
  
  # Check if API is working?
  
  count <- details$messages[1,6]
  message("Total number of records found: ",count)
  pages <- floor(count/100)
  
  # Create empty dataset
  df <- details$collection %>%
    dplyr::filter(doi == "")
  
  # Get data
  message("Starting extraction from API")
  
  
  for (cursor in 0:pages) {
    
    page <- cursor*100
    
    message(paste0("Extracting records ",page+1," to ",page+100, " of ", count))
    
    link <- paste0(base_link,"/",page)
    
    tmp <- httr::RETRY(verb = "GET", url = link) %>%
      httr::content(as = "text", encoding = "UTF-8") %>%
      jsonlite::fromJSON()
    
    tmp <- tmp$collection
    
    df <- rbind(df, tmp)
    
  }
  
  # Clean data
  
  if (clean == TRUE) {
    
    
    df$node <- seq_len(nrow(df))
    
    
    df <- df %>%
      dplyr::select(-c(.data$type,.data$server))
    
    df$link <- paste0("/content/",df$doi,"v",df$version,"?versioned=TRUE")
    df$pdf <- paste0("/content/",df$doi,"v",df$version,".full.pdf")
    df$category <- stringr::str_to_title(df$category)
    df$authors <- stringr::str_to_title(df$authors)
    df$author_corresponding <- stringr::str_to_title(df$author_corresponding)
    
  }
  
  if (include.info == TRUE) {
    details <-
      details$messages %>% dplyr::slice(rep(1:dplyr::n(), each = nrow(df)))
    df <- cbind(df, details)
  }
  
  df
  
}
####################################################################################################################################
# Run the above function/command and then start below
##################################################################

# Will download a copy of the bioRxiv repository
# Takes a long time!
bx_data <- bx_api_content()

#################################################
################### 
### based on this documentation: https://mcguinlu.github.io/medrxivr/articles/building-complex-search-strategies.html#building-your-search-with-boolean-operators
####################

topicStroke <- c("stroke")
#mouse OR rat OR rodent
topicSpecies <- c("mouse", "rat", "rodent")
topicDisease <- c("diabetes", "obesity", "metabolic syndrome")

# searches stroke AND (mouse OR rat OR rodent) AND diabetes
query <- list(topicStroke, topicSpecies, topicDisease)

# Then pass this data to mx_search, which will work as normal
resultsBiorXiv <- mx_search(data = bx_data,
                            query = query, 
                            from.date =20190625, to.date =20200703, NOT = c(""), 
                            fields = c("title", "abstract"), 
                            deduplicate = TRUE)




## Download the results PDFs - does not work with biorxiv DOIs as preffix URL is specified to medrxiv.org
# mx_download(resultsBiorXiv, directory = "pdf/", create = TRUE)

# change the preffix 
library(stringr)
resultsBiorXiv$link_pdf <- str_replace_all(resultsBiorXiv$link_pdf, "medrxiv", "biorxiv")
resultsBiorXiv$link_page <- str_replace_all(resultsBiorXiv$link_page, "medrxiv", "biorxiv")

mx_download(resultsBiorXiv, directory = "pdf/", create = TRUE)

### print the reuslts to a csv file
write.csv(resultsBiorXiv, file="biorxivResults.csv")
