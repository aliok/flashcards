import os
import pickle
import re
import urllib2
import sys
import argparse

__author__ = 'ali'

#fetch the wikipedia homepage
#follow "valid" wikipedia links
#   when found a link,
#        put it on a queue, to be visited later
#   when all links on current page is iterated thru
#        pop a URL from the queue and go to beginning
#        don't forget to mark it as visited, so we won't visit it again
#
#crawl until a number of articles are examined

BASE_URL = "http://de.wikipedia.org"

WIKIPEDIA_INTERNAL_LINK_PATTERN = re.compile(r'href="(?P<entry>/wiki/([^:"])*)"', re.UNICODE | re.IGNORECASE)
HTML_TAG_PATTERN = re.compile(ur"</?[^<][^>]*>", re.UNICODE | re.IGNORECASE)

HTML_WORD_PATTERN = re.compile(ur"(\w+)", re.UNICODE | re.IGNORECASE)

class Crawler:
    def __init__(self, numberOfArticles):
        self.articlesQueue = []
        self.visitedArticles = {}       #TODO: use set for this!
        self.wordCountsMap = {}
        self.numberOfArticles = numberOfArticles

    def startCrawling(self):
        self.articlesQueue.append("/wiki/Wikipedia:Hauptseite")
        self._crawl()

    def _crawl(self):
        crawledItemCount = 0
        while len(self.articlesQueue) and crawledItemCount < self.numberOfArticles:
            crawledItemCount += 1
            article = self.articlesQueue.pop(0)
            print '#Gonna inspect article #{} : {}'.format(crawledItemCount, article)
            print '#Items in the queue: ' + str(len(self.articlesQueue))

            self.visitedArticles[article] = True
            data = self.getArticleContent(article)

            #find wikipedia internal links and add articles to queue
            for (word, val) in WIKIPEDIA_INTERNAL_LINK_PATTERN.findall(data):
                if self.visitedArticles.has_key(word):
                    continue
                else:
                    print '\t#Adding article : {}'.format(word)
                    self.articlesQueue.append(word)


            #remove all html tags (not the children of the tags, but only the tags themselves)
            data = HTML_TAG_PATTERN.sub("", data)

            for word in HTML_WORD_PATTERN.findall(data):
                if self.isValidWord(word):
                    word = word.lower()
                    if self.wordCountsMap.has_key(word):
                        self.wordCountsMap[word] += 1
                    else:
                        self.wordCountsMap[word] = 1


    def getArticleContent(self, article):
        req = urllib2.Request(BASE_URL + article, headers={'User-Agent': "Magic Browser"})
        f = urllib2.urlopen(req)
        data = f.read().decode('utf-8')
        f.close()
        data = data.replace("\n", " ")
        return data


    def isValidWord(self, word):
        return len(word) >= 3 and not word.isdigit() and word.isalpha()
        #more rules here!


def main():
    parser = argparse.ArgumentParser(
        description='Crawls German Wikipedia until a number of articles and counts the words.\n'\
                    'For example: '\
                    '--operation crawl --stateFile state.dat --numberOfArticles 10 : Crawls 10 articles and save the '\
                    'state to file "state.dat". When you execute this command for the second time, the crawling '\
                    'operation will continue from the last state; it will not start from the beginning.')
    parser.add_argument('--operation', dest='operation', help='Operation to do', required=True,
        choices=['crawl', 'printState', 'printWordCounts', 'sortWordSet'])
    parser.add_argument('--stateFile', dest='stateFile', help='File to read/save the state of the crawler',
        required=True)
    parser.add_argument('--numberOfArticles', dest='numberOfArticles', type=int,
        help='Number of articles to crawl, default to 100', default=100)
    parser.add_argument('--setSize', dest='setSize', type=int,
        help='Set size for generated sorted words list, default to 100', default=100)

    args = parser.parse_args()

    crawler = None

    if os.path.exists(args.stateFile):
        print '#Found stateFile, trying to restore the crawler state.'
        with open(args.stateFile) as stateFile:
            try:
                crawler = pickle.load(stateFile)
            except Exception as e:
                if args.operation != 'crawl':
                    print 'Unable to restore crawler state.'
                    raise
                else:
                    print 'Unable to restore crawler state, creating new crawler.', e
    else:
        if args.operation != 'crawl':
            print "State file doesn't exist."
            raise Exception('Provided file does not exist')
        else:
            print "State file doesn't exist, creating new crawler."

    if args.operation == 'crawl':
        if not crawler:
            crawler = Crawler(args.numberOfArticles)
        else:
            crawler.numberOfArticles = args.numberOfArticles

        crawler.startCrawling()

        with open(args.stateFile, 'w') as stateFile:
            try:
                print 'Saving crawler state to file'
                pickle.dump(crawler, stateFile)
            except Exception as e:
                print 'Unable to save crawler state to file.', e

    elif args.operation == 'printState':
        print 'Crawler articles queue : {} items'.format(len(crawler.articlesQueue))
        for value in sorted(crawler.articlesQueue):
            print '\t' + value

        print 'Crawler visited articles : {} items'.format(len(crawler.visitedArticles))
        for value in sorted(crawler.visitedArticles):
            print '\t' + value

    elif args.operation == 'printWordCounts':
        sortedWordCountMap = sorted(crawler.wordCountsMap.iteritems(), key=lambda (k, v): (v, k), reverse=True)

        for key, value in sortedWordCountMap:
            print "{:<50} {:>5}".format(repr(key), value)

    elif args.operation == 'sortWordSet':
        #crawler.wordCountsMap
        import dictSet

        mergedWordCountMap = {}

        for entry in dictSet.dictSet:
            (article, word, translation) = entry
            count = 0
            if crawler.wordCountsMap.has_key(word.lower()):
                count = crawler.wordCountsMap[word.lower()]

            mergedWordCountMap[entry] = count

        mergedWordCountMap = sorted(mergedWordCountMap.iteritems(), key=lambda ((a,w,t), v): (v, (w,a,t)), reverse=True)

        mergedWordCountMap = mergedWordCountMap[0:15000]

        for i in range(0,len(mergedWordCountMap)/args.setSize):
            end = i*args.setSize + args.setSize
            if end >= len(mergedWordCountMap):
                end = len(mergedWordCountMap)-1

            print 'dictSet_{} = '.format(i), repr([key for (key,value) in mergedWordCountMap[i*args.setSize : end]])

        print 'dictSetCount={}'.format(len(mergedWordCountMap)/args.setSize)

if __name__ == "__main__":
    sys.exit(main())

    #./main.py --operation crawl --stateFile state.dat --numberOfArticles 10
    #./main.py --operation printState --stateFile state.dat
    #./main.py --operation printWordCounts --stateFile state.dat > output.txt
    #./main.py --operation sortWordSet --stateFile state.dat > sortedSet.txt