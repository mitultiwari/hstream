#!/usr/bin/python
# Crawl news.yc updates

import os, sys, re, traceback

def readNewComments():
  soup = getSoup('newcomments')
  comments = soup.findAll(attrs={'class': 'default'})
  for comment in comments:
    comhead = comment.find(attrs={'class': 'comhead'})
    saveItem(url(comhead, 'link'),
             computeTimestamp(comhead),
             computeAuthor(comhead),
             computeContents(comment),
             title=computeCommentTitle(comhead),
             parent=url(comhead, 'parent'),
             story=computeCommentStory(comhead))

def computeContents(comment):
  # Bug in BeautifulSoup; should be simply:
#?   contents = comment.find(attrs={'class': 'comment'})
#?   contents.name = 'div'
#?   return unicode(contents)
  comment.contents[0].extract() # HACK: mutating comment in place
  comment.find('br').extract()
  comment.find(attrs={'class': 'comment'}).name = 'div'
  return unicode(comment)

def readNewStories():
  soup = getSoup('newest')
  stories = soup.findAll(attrs={'class': 'title'})
  for title in stories:
    if not title.find('a'): continue
    if not title.parent.nextSibling: continue
    subtext = title.parent.nextSibling.find(attrs={'class': 'subtext'}) # crappy layout
    saveItem(computeStoryUrl(title, subtext),
             computeTimestamp(subtext),
             computeAuthor(subtext),
             title=unicode(title.find('a')),
             contents=computeStoryDesc(title))



def computeTimestamp(subtext):
  try: s = subtext.find(text=re.compile(r'\bago\b'))
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

import string
def computeAuthor(subtext):
  for link in subtext.findAll('a'):
    if string.find(link['href'], 'http://news.ycombinator.com/user?id=') == 0:
      return link.contents[0]
  return ''

def computeStoryUrl(title, subtext):
  try: return subtext.contents[4]['href']
  except IndexError: return title.find('a')['href']

def computeStoryDesc(title):
  url = title.find('a')['href']
  try: url.index(root)
  except ValueError: return ''

  for _ in dbRead('select hnid from items where hnid = %s' %(hnid(url))):
    print ("%s already saved; not bothering updating description" % (hnid(url)))
    return

  print "saving description"
  soup = getSoup(url)
  return ("<div class=\"comment\">"+computeStoryPageDesc(soup)+"</div>")

def computeStoryPageDesc(soup):
  subtext = soup.find(attrs={'class': 'subtext'})
  desc = subtext.parent.nextSibling.nextSibling # crappy empty tr
  if desc.find('form'):
    print 'FAIL'
    return ''
  return unicode(desc.contents[1])

def computeCommentStory(comhead):
  return comhead.find(text=re.compile('on: ')).nextSibling['href']

def computeCommentTitle(comhead):
  return unicode(comhead.find(text=re.compile('on: ')).nextSibling)



import urllib2
from BeautifulSoup import BeautifulSoup, Tag

def getSoup(url):
  sleep(30) # Crawl-delay in http://news.ycombinator.com/robots.txt
  log(url)
  soup = BeautifulSoup(urllib2.urlopen(absolutify(url)))
  for p in soup.findAll('a'):
    try: p['href'] = absolutify(p['href'])
    except KeyError:
      print 'a without href:', p
  return soup

# First url in soup with the given linktext
def url(soup, linktext):
  try: return soup.find('a', text=linktext).parent['href']
  except AttributeError: return ''

def hnid(url):
  if url is None: return 'NULL'
  return int(url.split('=')[1])

import json
try:
  with open('config/app.json') as fp:
    root = json.load(fp)['root']
except IOError:
  root = 'http://news.ycombinator.com'

def absolutify(url):
  if len(url) > 4 and url[:4] == 'http': return url
  if url[0] == '/': return root+url
  else: return root+'/'+url # assumption: relative == absolute urls



def saveItem(url, timestamp, author, contents, title=None, parent=None, story=None):
  log("  "+url)
  try:
    dbWrite("""insert into items (hnid,parent_hnid,story_hnid,timestamp,author,title,contents)
               values (%s,%s,%s,%s,%s,%s,%s)"""
        % (hnid(url), hnid(parent), hnid(story), timestamp, sqlForJs(author),
          sqlForJs(title), sqlForJs(contents)))
  except sqlite3.IntegrityError:
    if contents: # Ask HN stories won't refresh
      dbWrite("""update items set title=%s, contents=%s, timestamp=%s where hnid=%s"""
          % (sqlForJs(title), sqlForJs(contents), timestamp, hnid(url)))

def sqlForJs(s):
  if s: return "'"+s.replace("'", '&apos;')+"'"
  return 'null'

import sqlite3

def dbWrite(cmd):
  with sqlite3.connect('db/development.sqlite3') as conn:
    conn.execute(cmd)

def dbRead(cmd):
  for item in sqlite3.connect('db/development.sqlite3').execute(cmd):
    yield item



from time import time, ctime, sleep

def justTime(): return ctime()[11:-5]

def log(*args):
  print justTime(), ' '.join(map(str, args))
  sys.stdout.flush()



import httplib
while 1:
  try:
    readNewComments()
    readNewStories()
  except KeyboardInterrupt:
    traceback.print_exc(file=sys.stdout)
    break
  except:
    traceback.print_exc(file=sys.stdout)
