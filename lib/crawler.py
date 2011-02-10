#!/usr/bin/python
# Crawl news.yc updates

import os, sys, re



from time import time, ctime, sleep

def justTime(): return ctime()[11:-5]

def log(*args):
    print justTime(), ' '.join(map(str, args))
    sys.stdout.flush()



import sqlite3

def dbWrite(cmd):
  with sqlite3.connect('db/development.sqlite3') as conn:
    conn.execute(cmd)

def dbRead(cmd):
  for item in sqlite3.connect('db/development.sqlite3').execute(cmd):
    yield item



def loadState():
  base = 'http://news.ycombinator.com/item?id='
  for [_, comment, story] in dbRead('select * from crawler_state'):
    return [comment, story]
mostRecentComment, mostRecentStory = loadState()

def updateMostRecentComment(url):
  global mostRecentComment
  mostRecentComment = url
  dbWrite("update crawler_state set most_recent_comment = '%s'" %(url))

def updateMostRecentStory(url):
  global mostRecentStory
  mostRecentStory = url
  dbWrite("update crawler_state set most_recent_story = '%s'" % (url))

def saveItem(url, timestamp, author, parent, contents):
  log("  "+url)
  dbWrite("""insert into items (hnid,timestamp,author,parent_hnid,contents)
             values (%s,%s,'%s',%s,'%s')"""
      % (id(url),timestamp,author,id(parent),contents.replace("'", '&apos;')))

  dbWrite("insert into recentitems (hnid) values (%s)" % (id(url)))

def id(url):
  if url is None: return 'NULL'
  return int(url.split('=')[1])



import urllib2
from BeautifulSoup import BeautifulSoup, Tag

root = 'http://news.ycombinator.com'

def getSoup(url):
  sleep(1)
  soup = BeautifulSoup(urllib2.urlopen(absolutify(url)))
  for p in soup.findAll('a'):
    try: p['href'] = absolutify(p['href'])
    except KeyError:
      print 'a without href:', p
  return soup

def readNewComments(initurl):
  global mostRecentComment
  log('crawling new comments until', mostRecentComment)
  bound = mostRecentComment
  mostRecentComment = None

  while initurl != '':
    log(initurl)
    soup = getSoup(initurl)
    if mostRecentComment is None:
      updateMostRecentComment(url(soup, 'link'))

    comments = soup.findAll(attrs={'class': 'default'})
    for comment in comments:
      currUrl = url(comment, 'link')
      if currUrl == bound:
        return
      saveComment(comment, currUrl)

    initurl = url(soup, 'More')

def saveComment(comment, link=None):
  comhead = comment.find(attrs={'class': 'comhead'})
  saveItem(link or url(comhead, 'link'),
           computeTimestamp(comhead),
           computeAuthor(comhead),
           url(comhead, 'parent'),
           unicode(comment))

def readNewStories(initurl):
  global mostRecentStory
  log('crawling new stories until', mostRecentStory)
  bound = mostRecentStory
  mostRecentStory = None

  while initurl != '':
    log(initurl)
    soup = getSoup(initurl)
    if mostRecentStory is None:
      # assumption: newest story hasn't comments yet.
      updateMostRecentStory(url(soup, 'discuss'))

    stories = soup.findAll(attrs={'class': 'title'})
    for s in stories:
      if s.find('a') is not None:
        if s.parent.nextSibling is not None:
          currUrl = urlOfStoryTitle(s)
          if currUrl == bound:
            return
          saveStory(s, currUrl)

    initurl = url(soup, 'More')

def saveStory(title, link=None):
  subtext = title.parent.nextSibling.contents[1]
  saveItem(link or url(subtext, 'discuss'),
           computeTimestamp(subtext),
           computeAuthor(subtext),
           parent=None,
           contents=unicode(title.find('a')))

def urlOfStoryTitle(title):
  subtext = title.parent.nextSibling.contents[1]
  try: return subtext.contents[4]['href']
  except IndexError: return title.find('a')['href']

# First url in soup with the given linktext
def url(soup, linktext):
  try: return soup.find('a', text=linktext).parent['href']
  except AttributeError: return ''

def absolutify(url):
  if len(url) > 4 and url[:4] == 'http': return url
  if url[0] == '/': return root+url
  else: return root+'/'+url # assumption: relative == absolute urls

def computeTimestamp(subtext):
  try: s = subtext.contents[3]
  except IndexError: return 0

  now = time()

  r = re.compile('\s*(\d+) minutes? ago.*')
  if r.match(s):
    return now-int(re.sub(r, '\\1', s))*60

  r = re.compile('\s*(\d+) hours? ago.*')
  if r.match(s):
    return now-int(re.sub(r, '\\1', s))*60*60

  r = re.compile('\s*(\d+) days? ago.*')
  if r.match(s):
    return now-int(re.sub(r, '\\1', s))*60*60*24

  return 0

def computeAuthor(subtext):
  try: return str(subtext.contents[2].string)
  except IndexError: return ''



def recency(item):
  for ts in dbRead("select timestamp from items where hnid=%s" % (item)):
    return time() - ts[0]

RECENCY_THRESHOLD = 5 # seconds; sync with templates

def pruneRecentItems():
  for item in [items[0] for items in dbRead("select hnid from recentitems")
                          if recency(items[0]) > RECENCY_THRESHOLD]:
    log("deleting %s" % (item))
    dbWrite("delete from recentitems where hnid=%s" % (item))
  log("recent items: %s"
      % ([x[0] for x in dbRead("select hnid from recentitems")]))



import httplib
while 1:
  try:
    readNewComments('newcomments')
    readNewStories('newest')
    pruneRecentItems()
  except (urllib2.URLError, httplib.BadStatusLine):
    pass
  except 'bad item':
    pass
