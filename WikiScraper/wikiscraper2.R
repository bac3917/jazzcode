
### Purpose of code: this code takes a list of jazz musicians and scrapes biographical information from Wikipedia about 
### each musician and places it into a dataframe
### Later will MERGE other jazz data to this dataframe using musician first/last name

### Known issues: some musicians are not listed on Wikipedia, and some musicians will not have information 
### in the Wikipedia class named "table.infobox.vcard.plainlist"

### Possible approaches:  
###         1. scrape specific data elements from the infobox, such as name and instruments  or  
###            in this way, you can keep the HTML/XML structure of the content. It should be easier thatn approach 2.
###         2. grab all infobox data and parse it subsequently (this approach is shown below)
###            In this way, you have to use regular expression to extract the information. Learning curve for regular expression is steep.
###            Once you master it, it is extremely useful, but it will take some time.

library(rvest)
library(stringr)
jazzlist<-c("Art Pepper","Horace Silver","Art Blakey","Philly Joe Jones", "Miles Davis","Thelonius Monk", "John Coltrane","Max Roach")
target_pages = paste0('https://en.wikipedia.org/wiki/Special:Search/', gsub(" ", "_", jazzlist))

# grab all text from Wikipedia infobox
data <- data.frame()
for (url in target_pages){
    webpage = read_html(url)
    # do whatever else you want here with rvest functions 
    info<-webpage %>% html_nodes(xpath='//*[contains(concat( " ", @class, " " ), concat( " ", "plainlist", " " ))]') %>%
        html_text() 
    temp<-data.frame(info, stringsAsFactors = FALSE)
    data = rbind(data,temp) #combines each result/page into a df
}

# note: curent code creates extra rows with useless information

# cleaning steps
library(data.table)
library(stringr)
library(dplyr)
library(tibble)


# parsing 
# data$name<-str_extract(data4..........????
#                            data$birthyear<-str_extract(data4..........????
#                                                            data$deathyear<-str_extract(data4..........????
#                                                                                            data$label<-str_extract(data4..........????
                                                                                                                       
# method 1:--------------------------------
# extract inforamtion from the infobox and keep xml structure.

# let's use 1 url for testing
test_url <- "https://en.wikipedia.org/wiki/Special:Search/Art_Pepper" 
#get the infobox node while maintaining its xml structure
infobox_node <- read_html(test_url) %>%
    html_node(".infobox ")
#after studying the HTML structure using google chrome developer tools, 
#I find that only nodes with `th[scope='row']` contains information we need
#so let's use xml2 library to find parent nodes for `th[scope='row']` nodes
#and only keep them
nodes_with_info <- infobox_node %>% html_nodes("th[scope='row']") %>% xml_parent()
#get titles or column names for the content
info_title <- nodes_with_info %>% html_nodes("th[scope='row']") %>% html_text()
#get content
info_content <- nodes_with_info %>% html_nodes("td") %>% html_text() %>% str_trim(side="both")
#bind them into a named vector
result_vector <- info_content %>% setNames(info_title)
#convert to data frame
result_df <- dplyr::bind_rows(result_vector)

# let's use target_pages and create a loop for testing
result_df <- tibble()
for(my_page in target_pages){
    test_url <- my_page
    infobox_node <- read_html(test_url) %>%
        html_node(".infobox ")
    nodes_with_info <- infobox_node %>% html_nodes("th[scope='row']") %>% xml_parent()
    info_title <- nodes_with_info %>% html_nodes("th[scope='row']") %>% html_text()
    info_content <- nodes_with_info %>% html_nodes("td") %>% html_text() %>% str_trim(side="both")
    result_vector <- info_content %>% setNames(info_title)
    result_df <- dplyr::bind_rows(result_df,result_vector)  
}
# the result looks good. some columns are missing because the information is also missing in the original wiki pages.

# Method 2:--------------
# Though Method 2 is doable, it cloud be overly complicated by using a lot of regular expression. 
# And the performance will also be worse because regular expression search through all texts
# and drains computing power.
