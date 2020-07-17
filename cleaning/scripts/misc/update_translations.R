library(tidyverse)
library(googleLanguageR)

# Translation with Google Translate API

# This will work if you setup Google Translate API and set the location of your 
# credential json file in .Renviron  GL_AUTH.
# See: https://cran.r-project.org/web/packages/googleLanguageR/vignettes/setup.html

update_translations <- function(column_to_translate, file, source_language){
  
  file_path <- paste0("cleaning/api_responses/", file)
  
  if (file.exists(file_path)){
    translations <-  read_rds(file_path)
    translations_needed <- unique(column_to_translate[!(column_to_translate %in% translations$text)])
  } else{
    translations <- NULL
    translations_needed <- unique(column_to_translate)
  }
  
  # Do we need more translations
  if (length(translations_needed != 0)){
    
    new_translations <- gl_translate(translations_needed, target = "en", source = source_language) 
    
    translations <-     
      rbind(translations, new_translations) %>% 
      distinct(text, .keep_all = TRUE)
    
    write_rds(translations, file_path)
  }
  
  # Join translations onto origional column and return translated column
  tibble(
    text = column_to_translate
  ) %>% 
    left_join(
      translations,
      by = "text"
    ) %>% 
    pull(translatedText)
  
}
