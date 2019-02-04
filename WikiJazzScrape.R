
### Wikipedia Jazz Data Scraper

# Test for one page:
url<-"https://en.wikipedia.org/wiki/Philly_Joe_Jones"


name <-PJJ %>% read_html() %>% #scrape name
        html_nodes(xpath="//th") %>%
        html_text()

dob<-PJJ %>% read_html() %>%   #scrape date of birth
        html_nodes(xpath="//tr[(((count(preceding-sibling::*) + 1) = 5) and parent::*)]//td") %>%
        html_text()

dod<-PJJ %>% read_html() %>%    #scrape date of death
        html_nodes(xpath="//tr[(((count(preceding-sibling::*) + 1) = 6) and parent::*)]//td")%>%
        html_text()

instruments<-PJJ %>% read_html() %>%  #scrape instruments played
        html_nodes(xpath="//tr[(((count(preceding-sibling::*) + 1) = 9) and parent::*)]//td")%>%
        html_text()

# clean up results
name2<-str_extract(paste(name,collapse="\n"), "(.*)[^\n]")
dob2<-str_extract(dob,'\\(.{11}')
dod2<-str_extract(dod,"\\(.{10}")

# make data frame
artists<-as.data.frame(cbind(name2,dob2,dod2,instruments))



############# Multipage Scraper  ##############
# short test list of musicians
# full list will be hundreds of musicians
# goal is to search Wikipedia for the names below and return name, dob, etc
jazzlist<-c("Art Pepper","Horace Silver","Art Blakey","Philly Joe Jones")

# use lapply to iterate over different jazz artists:
# https://stackoverflow.com/questions/42607206/scraping-information-from-multiple-webpages-using-rvest?rq=1

Results.list<-lapply(jazzlist,function(x){
        
        # Target URL for each musician
        link <-sprintf("https://en.wikipedia.org/wiki/Special:Search/%s/", x) %>% 
                read_html() %>% 
                html_nodes(xpath="//th") %>%
                html_text()
        
        # Find the total number of pages to scrape
        tot_pages <- read_html(link) %>%
                html_nodes(xpath="//th") %>% html_text()
        
        # Store the URLs in a vector
        URLs <- sprintf("https://en.wikipedia.org/wiki/%s/" ,x, 1:tot_pages)
        
        #Create a progress bar
        pb <- progress_estimated(tot_pages, min = 0)
        
        # Create a function to scrape the name and DOB from each page
        getdata <- function(URL) {
                pb$tick()$print()
                pg <- read_html(URL)
                html_nodes(pg, xpath='xpath="//th"') %>% html_text()%>%
                        as_tibble() %>% set_names(c('ArtistName')) %>%
                        mutate(dob = html_nodes(pg, xpath="//tr[(((count(preceding-sibling::*) + 1) = 5) and parent::*)]//td") %>% html_text())
        }
        
        map_df(URLs, getdata) -> results
        
        # add an id column indicating which year
        results$year <- x
        
        return(results)
        
})
