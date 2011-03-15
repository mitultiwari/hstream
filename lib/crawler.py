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
             unicode(comment),
             url(comhead, 'parent'))

def readNewStories():
  soup = getSoup('newest')
  stories = soup.findAll(attrs={'class': 'title'})
  for title in stories:
    if not title.find('a'): continue
    if not title.parent.nextSibling: continue
    subtext = title.parent.nextSibling.contents[1]
    saveItem(computeStoryUrl(title, subtext),
             computeTimestamp(subtext),
             computeAuthor(subtext),
             unicode(title.find('a')) +
               "<div class=\"subtext\">"+unicode(subtext)+"</div>",
             parent=None)



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

def computeStoryUrl(title, subtext):
  try: return subtext.contents[4]['href']
  except IndexError: return title.find('a')['href']



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



def saveItem(url, timestamp, author, contents, parent):
  log("  "+url)
  try:
    dbWrite("""insert into items (hnid,timestamp,author,parent_hnid,contents)
               values (%s,%s,'%s',%s,'%s')"""
        % (hnid(url),timestamp,author,hnid(parent),contents.replace("'", '&apos;')))
    sendNotifications(hnid(url), contents, author) # only on first write
  except sqlite3.IntegrityError:
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



notifications = [
                 ['hackerstream', 'akkartik@gmail.com', 'akkartik'],
                 ['hackerstream', 'mitultiwari@gmail.com', 'mitultiwari'],
                 ['akkartik', 'akkartik@gmail.com', 'akkartik'],
                 ['mitultiwari', 'mitultiwari@gmail.com', 'mitultiwari'],
                 ['readwarp', 'akkartik@gmail.com', 'akkartik'],
                 ['hystry', 'akkartik@gmail.com', 'akkartik'],
                 ['paulgraham', 'akkartik@gmail.com', 'akkartik'],
                 ['iamelgringo', 'akkartik@gmail.com', 'akkartik'],
                 ['swombat', 'akkartik@gmail.com', ''],
                 ['swombat.com', 'daniel.tenner@gmail.com', 'swombat'],
                ]

def sendNotifications(hnid, contents, author):
  for pattern, email, hnuser in notifications:
    if re.search('\W'+pattern+'\W', contents, re.I) and author != hnuser:
      print 'notifying', email, 'of', hnid
      sendmail(kwdmatch_email(email, pattern, hnid))

def kwdmatch_email(to, keyword, hnid):
    return """To: %s
Subject: New story on HN about %s

http://news.ycombinator.com/item?id=%s""" %(to, keyword, hnid)

def sendmail(msg):
  try:
    with os.popen("/usr/sbin/sendmail -t -f authsmtp@akkartik.com", "w") as sendmail:
      sendmail.write(msg)
  except:
    traceback.print_exc(file=sys.stdout)



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
