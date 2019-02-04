

#discogs API
rm(list=ls())

# Load packages
library(tidyverse);library(expss);library(httr);library(jsonlite)

# resource: https://tclavelle.github.io/blog/r_and_apis/
# https://github.com/bartve/disconnect

# probably best?  https://colinfay.me/data-vinyles-discogs-r/


setwd("K:/bac/jazzdBase")
# Save username as variable
username <- 'bac3917'

# Save base enpoint as variable 
url_discogs <- 'https://api.discogs.com/'

# THIS FRENCH GUY HAS THE EXACT SOLUTION: https://colinfay.me/data-vinyles-discogs-r/ 


# Construct API request
# https://www.discogs.com/developers/#page:database,header:database-artist-releases-get

library(jsonlite) library(DT);library(magrittr) #for %>%

# Benny Green
BG<-as.data.frame( fromJSON("https://api.discogs.com/artists/96442/releases"))
BG$releases.title
library(data.table);library(DT)
BG2<-BG[ ,c(9:11,13,19)]
BG2 %>% DT::datatable() %>% 
        formatStyle(columns=c(1,2,3,4,5),fontSize='80%') %>%
        formatStyle(columns=1,fontWeight =  'bold')

# make a list of all BG titles, search for personnel on those titles
# https://www.discogs.com/help/database/submission-guidelines-release-credits




#############

releasesHM1 <-as.data.frame( fromJSON("https://api.discogs.com/artists/135872/releases?page=1&per_page=375")  );releasesHM1$mainartist<-"Hank Mobley";releasesHM1<-releasesHM1[keepvars]
HM<-releasesHM1[ ,c(9:11,13,19)]
HM %>% DT::datatable() %>% 
        formatStyle(columns=c(1,2,3,4,5),fontSize='80%') %>%
        formatStyle(columns=1,fontWeight =  'bold')

# https://stackoverflow.com/questions/54112269/using-r-to-scrape-discogs/54113369#54113369
keepvars<-c("releases.year","mainartist","releases.title","releases.main_release")
releasesHM1 <-as.data.frame( fromJSON("https://api.discogs.com/artists/135872/releases?page=1&per_page=375")  );releasesHM1$mainartist<-"Hank Mobley";releasesHM1<-releasesHM1[keepvars]
releasesHM2 <-as.data.frame( fromJSON("https://api.discogs.com/artists/135872/releases?page=2&per_page=375")  );releasesHM2$mainartist<-"Hank Mobley";releasesHM2<-releasesHM2[keepvars]
  releasesHM<-bind_rows(releasesHM1,releasesHM2) # must choose vars before bind
  HMde.duped<-as.data.frame(unique(releasesHM[ ,3]))
      
  releasesMDavis1 <-as.data.frame( fromJSON("https://api.discogs.com/artists/23755/releases?page=1&per_page=375"));releasesMDavis1$mainartist<-"Miles Davis";releasesMDavis1<-releasesMDavis1[keepvars]
releasesMDavis2 <-as.data.frame( fromJSON("https://api.discogs.com/artists/23755/releases?page=2&per_page=375"));releasesMDavis2$mainartist<-"Miles Davis";releasesMDavis2<-releasesMDavis2[keepvars]
  releasesMDavis<-bind_rows(releasesMDavis1,releasesMDavis2 )
  MDavisde.duped<-as.data.frame(unique(releasesMDavis[ ,3]))

  # The Gentle Side of John Coltrane   master=[m344700]
releasesColtrane1 <-as.data.frame( fromJSON("https://api.discogs.com/artists/97545/releases?page=1&per_page=375"));releasesColtrane1$mainartist<-"Coltrane";releasesColtrane1<-releasesColtrane1[keepvars]
releasesColtrane2 <-as.data.frame( fromJSON("https://api.discogs.com/artists/97545/releases?page=2&per_page=375"));releasesColtrane2$mainartist<-"Coltrane";releasesColtrane2<-releasesColtrane2[keepvars]
  releasesColtrane<-bind_rows(releasesColtrane1,releasesColtrane2)

# a subset of these are 'main releases'
# search and select for an m prefix?
releasesColtrane$keep<-ifelse(str_detect(releasesColtrane$releases.main_release,"m"),1,0)
ColtraneMain<-as.data.frame(
        releasesColtrane1[which(releasesColtrane1$keep==1), ] )
  
library(dplyr);library(ggrepel)
releases<-bind_rows ( list(HMde.duped,MDavisde.duped,releasesColtrane))
fre(releases$releases.year)

g<-ggplot(releases, aes(releases.year),label=releases.title)+
        geom_bar(data=releases,aes(fill=releases$mainartist ),position = 'dodge')+
        ylab("Number Albums Released")+xlab("Year")+theme_grey()

releases2<-releases[sample(1:nrow(releases),89), ]
releases2$title2<-substr(releases2$releases.title,1,35)
ggplot(releases2, 
                aes(x=releases.year,y=1, label=releases2$title2))+
        geom_point(color="blue")+
        geom_text_repel(
                nudge_y      =4,
                direction="x",angle= 90, vjust= 0,
                segment.size = 0.2,size=3  )+
        xlim(1950,2020)+ ylim(1,30)+
        theme(axis.line.y  = element_blank(),
                axis.ticks.y = element_blank(),
                axis.text.y  = element_blank(),
                axis.title.y = element_blank()        )+
        xlab("Year of Album Release")+
        facet_wrap(~mainartist)
        

library(plotly)
ggplotly(g)


HMcaddy <- fromJSON("https://api.discogs.com/masters/239711/versions")

HMcaddy$versions$released

# The Artist resource represents a person in the Discogs database who contributed to a Release in some capacity.
MONKreleases<-fromJSON("https://api.discogs.com/artists/145256/releases")        
MONKreleases$releases$year
plot(MONKreleases$releases$year)

ROYAYERS<-fromJSON("https://api.discogs.com/artists/2265/releases")  #played with Lee Morgan   
write.csv(ROYAYERS,"temp.csv")


# Columbia Records 1866
ColumbiaM<-fromJSON("https://api.discogs.com/labels/1866/releases")


# Discogs seems to have put a rate limit on its API. 
# For the creation of collection_2, you should consider using Sys.sleep(). 


# lists help keep a variety of different data handy for a variety of tasks; could include a list containing
# key variable names, coordiates, names, etc... in one list with different 'bags'

# https://www.discogs.com/developers/#page:database,header:database-all-label-releases-get

labelid<-'37828'  # Capitol Jazz [l37828]

# NOTE: the httr command GET results in a vector named "content" (see httr helpfile)
label_url <- httr::GET(paste0("https://api.discogs.com/labels/",labelid,"/releases/",
                              content[[1]]$id,"?page=1&amp;per_page=100"))

label_url <- fromJSON(paste0("https://api.discogs.com/labels/",labelid,"/releases/"))
label_url <- fromJSON(paste0("https://api.discogs.com/labels/37828/releases/"))


ww<-httr::GET("https://api.discogs.com/database/search?release_title=nevermind&artist=nirvana&per_page=3&page=1")
ww[6]

label_url <- fromJSON(paste0("https://api.discogs.com/labels/l37828/releases") )
label_url

# Timeline - number releases by year for a label
labelcontent <- rjson::fromJSON(rawToChar(content$content))$title
labelcontent


if (label_url$status_code == 200){
        labelcontent <- rjson::fromJSON(rawToChar(label_url$content))
        labeldata <- labelcontent$id
        if(!is.null(labels$pagination$urls$`next`)){
                repeat{
                        url <- httr::GET(labels$pagination$urls$`next`)
                        labels <- rjson::fromJSON(rawToChar(url$content))
                        labeldata <- c(labeldata, labels$name)  #to determine avail vars, open URL that yer searching: e.g. https://api.discogs.com/labels/1561
                        if(is.null(labels$pagination$urls$`next`)){
                                break
                        }
                }
        }
}

head(labelcontent)
labelcontent[[3]]

labelset <- lapply(labeldata, function(obj){
        data.frame(release_id = obj$basic_information$id %||% NA,
                   label = obj$basic_information$labels[[1]]$name %||% NA,
                   year = obj$basic_information$year %||% NA,
                   title = obj$basic_information$title %||% NA, 
                   artist_name = obj$basic_information$artists[[1]]$name %||% NA,
                   artist_id = obj$basic_information$artists[[1]]$id %||% NA,
                   artist_resource_url = obj$basic_information$artists[[1]]$resource_url %||% NA, 
                   format = obj$basic_information$formats[[1]]$name %||% NA,
                   resource_url = obj$basic_information$resource_url %||% NA)
}) %>% do.call(rbind, .) %>% 
        unique()

head(labelset)





#########################

const fetch = require('node-fetch');
const config = require('./config.json');

const search = (query, type = 'q') => {
        fetch(`${config.apiUrl}/database/search?${type}=${query}`,
                            {
                      method: "GET",
                      headers: {
                              "Authorization": "Discogs key=MY_API_KEY, secret=MY_API_SECRET"
                      }
              }
        )
        .catch(err => console.error(err))
        .then(res => console.log(res));
}

search('nirvana');

