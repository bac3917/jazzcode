#set up ----------------
library(tidyverse) # for various packages: purrr,dplyr and etc.
library(httr) #add advanced functionality like user-agent to rvest
library(rvest) #for web scraping
library(stringr) #for string manipulation
source("utility/random_agent.R") #load custom function to spoof user agents and not get blocked by websites.
source("utility/rotate_proxy.R") #load custom function to use proxies, this website is blocking ip sending too many requests, so I have to use proxies
my_proxy <- read_csv("userpackagesIppacks.csv") #load my proxies table
html_session_new <- function(url){
    # by delting rotate_proxy(proxy_table = my_proxy), you can try to run the script without proxy
    # but you may be banned soon
    html_session(url,random_agent(),rotate_proxy(proxy_table = my_proxy),timeout(10))
}

home_page <- "https://www.jazzdisco.org/"

#get links to all labels -------------------
record_label_href <- html_session_new(home_page) %>%
    html_nodes(".headline+ ul a") %>%
    html_attr("href")

record_label_link <- str_sub(home_page,end = -2) %>%
    str_c(record_label_href)

#get links to all albums ---------------
all_album_links <- c()
#loop to get links to all albums
for(current_label in record_label_link){
    #find link to catalog by text ---------
    current_session <- html_session_new(current_label)
    all_link <- current_session %>% html_nodes("a") 
    all_link_text <- all_link %>% html_text()
    catalog_index <- which(str_detect(all_link_text,"Catalog"))
    catalog_link_href <- all_link[catalog_index] %>% html_attr("href")
    current_catalog_link <- str_sub(home_page,end = -2) %>%
        str_c(catalog_link_href)
    #append current links to all_album_links
    all_album_links <- append(all_album_links,current_catalog_link)
}

global_sleep_time <- 30 #set long sleep time to avoid being blocked

#loop all albums to get desired result(310 pages to scrape)------------------------------
#The following lines use same template for scraping: whenever a request is failed, it is attempted for at most 3 times, if all attempts failed,
#it will be stored for retrying later(at most three times).
final_output <- tibble() #initialize final result table
failed_links <- character()#keep track of failed links
for(album in all_album_links){
    #auto retry request if request failed ------------
    page_result <- NULL
    time_tried <- 1
    while(is.null(page_result) & time_tried <= 3){
        page_result <- tryCatch(page_scraper(album),
                                error=function(e){
                                    cat("time tried: ",time_tried,"\n")
                                    Sys.sleep(global_sleep_time)
                                    return(NULL)
                                })
        time_tried <- time_tried + 1
    }
    
    if(is.null(page_result)){
        cat("all tries failed,save result to failed_links\n")
        failed_links <- append(failed_links,album)
        next()
    }
    
    final_output <- bind_rows(final_output,page_result)
    Sys.sleep(global_sleep_time) # sleep betwwen each album
    scrape_process <- match(album,all_album_links)
    cat(scrape_process," of ",length(all_album_links)," completed; ","time: ",as.character(Sys.time()),"\n")
}

# try failed_links again ----------------
still_failed <- character()
for(album in failed_links){
    #auto retry request if request failed ------------
    page_result <- NULL
    time_tried <- 1
    while(is.null(page_result) & time_tried <= 3){
        page_result <- tryCatch(page_scraper(album),
                                error=function(e){
                                    cat("time tried: ",time_tried,"\n")
                                    Sys.sleep(global_sleep_time)
                                    return(NULL)
                                })
        time_tried <- time_tried + 1
    }
    
    if(is.null(page_result)){
        still_failed <- append(still_failed,album)
        next()
    }
    
    final_output <- bind_rows(final_output,page_result)
    Sys.sleep(global_sleep_time) # sleep five second betwwen each album
    scrape_process <- match(album,failed_links)
    cat(scrape_process," of ",length(failed_links)," completed; ","time: ",as.character(Sys.time()),"\n")
}

#try the third time------

final_failed <- character()
for(album in still_failed){
    #auto retry request if request failed ------------
    page_result <- NULL
    time_tried <- 1
    while(is.null(page_result) & time_tried <= 3){
        page_result <- tryCatch(page_scraper(album),
                                error=function(e){
                                    cat("time tried: ",time_tried,"\n")
                                    Sys.sleep(global_sleep_time)
                                    return(NULL)
                                })
        time_tried <- time_tried + 1
    }
    
    if(is.null(page_result)){
        final_failed <- append(final_failed,album)
        next()
    }
    
    final_output <- bind_rows(final_output,page_result)
    Sys.sleep(global_sleep_time) # sleep five second betwwen each album
    scrape_process <- match(album,still_failed)
    cat(scrape_process," of ",length(still_failed)," completed; ","time: ",as.character(Sys.time()),"\n")
}

write.csv(final_output,"final_output.csv")
