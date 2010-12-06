#!/usr/bin/python
# Crawl news.yc updates

import os, sys, re



from time import time, ctime, sleep

def justTime(): return ctime()[11:-5]

def log(*args):
    print justTime(), ' '.join(map(str, args))
    sys.stdout.flush()



import sqlite3
import json

def loadState():
  # TODO
  return [None, None]
mostRecentComment, mostRecentStory = loadState()

def saveState():
  # TODO
  pass

def saveItem(url, timestamp, author, parent, contents):
  log(url)
  conn = sqlite3.connect('db/development.sqlite3')
  c = conn.cursor()
  c.execute("""insert into items (hnid,timestamp,author,parent_hnid,contents)
                values (%s,%s,'%s',%s,'%s')"""
      % (id(url),timestamp,author,id(parent),contents.replace("'", "&apos;")))
  conn.commit()
  c.close()

def id(url):
  if url is None: return 'NULL'
  return url.split('=')[1]



import urllib2
from BeautifulSoup import BeautifulSoup, Tag

root = 'http://news.ycombinator.com/'

def getSoup(url):
  sleep(1)
  soup = BeautifulSoup(urllib2.urlopen(absolutify(url)))
  for p in soup.findAll('a'):
    try: p['href'] = absolutify(p['href'])
    except KeyError:
      print "a without href:", p
  return soup

def readNewComments(initurl):
  global mostRecentComment
  log('crawling new comments until', mostRecentComment)
  bound = mostRecentComment
  mostRecentComment = None

  while initurl != '':
    soup = getSoup(initurl)
    if mostRecentComment is None: mostRecentComment = url(soup, 'link')

    comments = soup.findAll(attrs={'class': 'default'})
    for comment in comments:
      u = url(comment, 'link')
      if u == bound:
        return
      saveComment(comment, u)

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
    soup = getSoup(initurl)
    if mostRecentStory is None: mostRecentStory = url(soup, 'discuss') # Kludge: assume newest story hasn't comments yet.

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
  # Kludge: relative == absolute urls
  if len(url) <= 5 or url[4] != ':': return root+url
  return url

def computeTimestamp(subtext):
  try: s = subtext.contents[3]
  except IndexError: return 0

  now = time()

  r = re.compile("\s*(\d+) minutes? ago.*")
  if r.match(s):
    return now-int(re.sub(r, '\\1', s))*60

  r = re.compile("\s*(\d+) hours? ago.*")
  if r.match(s):
    return now-int(re.sub(r, '\\1', s))*60*60

  r = re.compile("\s*(\d+) days? ago.*")
  if r.match(s):
    return now-int(re.sub(r, '\\1', s))*60*60*24

  return 0

def computeAuthor(subtext):
  try: return str(subtext.contents[2].string)
  except IndexError: return ''

import httplib
while 1:
  try:
    readNewComments('newcomments')
    readNewStories('newest')
    saveState()
  except (urllib2.URLError, httplib.BadStatusLine):
    pass
  except "bad item":
    pass
