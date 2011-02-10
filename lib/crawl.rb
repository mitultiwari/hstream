require 'rubygems' 
require 'mongo'
require 'net/http'
require 'net/https'
require 'hpricot'
require 'uri'


def getUrl(url)
  puts "getUrl: #{url}\n"
  res = Net::HTTP.get_response(URI.parse(url))
  case res
  when Net::HTTPSuccess then res.body
  else res.error
  end
end

def getRecentStories()
  content = getUrl("http://news.ycombinator.com/newest")
#print content
  doc = Hpricot(content)
#print doc.search("//td[@class='title']")
  url_titles = doc.search("//td[@class='title']")
  url_titles.each{ |item| 
    url_title = item.search("/a")
    #url = url_title.attributes['href']
    title = url_title.innerHTML 
    print "#{title}\n"
  }
end

getRecentStories()
  

