#!/usr/bin/python
# Crawl news.yc updates

import os, sys, re, traceback

def readNewComments():
  soup = getSoup('newcomments')
  comments = soup.findAll(attrs={'class': 'default'})
  for comment in comments:
    saveComment(comment)

def readNewStories():
  soup = getSoup('newest')
  stories = soup.findAll(attrs={'class': 'title'})
  for s in stories:
    if s.find('a') is not None and s.parent.nextSibling is not None:
      saveStory(s)

def saveComment(comment):
  comhead = comment.find(attrs={'class': 'comhead'})
  saveItem(url(comhead, 'link'),
           computeTimestamp(comhead),
           computeAuthor(comhead),
           url(comhead, 'parent'),
           unicode(comment))

def saveStory(title):
  subtext = title.parent.nextSibling.contents[1]
  saveItem(computeStoryUrl(title, subtext),
           computeTimestamp(subtext),
           computeAuthor(subtext),
           parent=None,
           contents=unicode(title.find('a'))+"<div class=\"subtext\">"+unicode(subtext)+"</div>")

def computeStoryUrl(title, subtext):
  try: return subtext.contents[4]['href']
  except IndexError: return title.find('a')['href']

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



import urllib2
from BeautifulSoup import BeautifulSoup, Tag

def getSoup(url):
  sleep(30)
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



def saveItem(url, timestamp, author, parent, contents):
  log("  "+url)
  try:
    dbWrite("""insert into items (hnid,timestamp,author,parent_hnid,contents)
               values (%s,%s,'%s',%s,'%s')"""
        % (hnid(url),timestamp,author,hnid(parent),contents.replace("'", '&apos;')))
  except sqlite3.IntegrityError:
    log('  update')
    dbWrite("""update items set contents = '%s' where hnid=%s"""
        % (contents.replace("'", '&apos;'), hnid(url)))

import sqlite3

def dbWrite(cmd):
  with sqlite3.connect('db/production.sqlite3') as conn:
    conn.execute(cmd)

def dbRead(cmd):
  for item in sqlite3.connect('db/production.sqlite3').execute(cmd):
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
