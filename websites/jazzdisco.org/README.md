
## File Explanations:

1. **final_output.csv**	    
    * Final scraping results.
  
2. **page_scraper.R**  
    * A excutable script unit to scrape a given catalog page.    
    * Since jazzdisco.org has poor HTML layout, many regular expressions and methods like modifying xml trees are used to extract information. While some of these methods are rarely used in websites with better HTML structure.

3. **main.R**  
    * run this script to repeat the web-scraping process. 
    * I used proxy in line 11 with function `rotate_proxy()`. To make this script immediately runnable, you can delete this function or use your own proxy by adding argument `rotate_proxy(proxy_table = your_proxy)`. You can load your proxy table at line 8. To make your proxy work, you need to modify function [`rotate_proxy`](https://github.com/bac3917/jazzDbase/blob/master/utility/rotate_proxy.R) in utility folder from line 13 to line 16. 
    * Since request may fail and I don't want to lose information on any pages, I wrote three "*for-while-loop*". So failed request can be retried at most 9 times. If you want to save some time and are OK to lose information on some pages, you can comment out the last one or two "*for-while-loop*".
    * I set waiting time between each page script 30 seconds. If you are using the script withoug proxy, increase it to at least 60 seconds. If you have some proxies in different ip range, you can reduce it to 10 to 20 seconds. If you have hundreds of proxies, you can reduce it to 1~3 seconds.


## Notes:

The missing values for each column is:

| Column          | Percentage Missing |
|-----------------|--------------------|
| AlbumCode       | 0%                 |
| LeadArtist      | 14%                |
| AssociateArtist | 3%                 |

Overall percentage of complete observations are 85.83%.

Some missing values are due to lack on information on jazzdisco.org, so we can not get them anyway.(e.g. some albums don't have lead Artist thus displayed as "Various Artist"; Some albums don't display Lead Artist's name)   

Since I use regular expression to extract information, it's possible to modify existing ones to reduce the amount of missing values. But modify regular expression based on various situations can be extremely tedious and time consuming. It may easily take three or four more hours to do it but only increase percentage of complete observations by 2% to 4%. Depending on your analysis, it may or may not worth the time and effort.
