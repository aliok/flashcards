import webapp2
from google.appengine.ext import db
import zipfile
import pickle
from model import Entry
import logging

class InitializeHandler(webapp2.RequestHandler):
    def get(self):
        logging.basicConfig(level=logging.DEBUG)

        logging.debug('starting to read file')
        with zipfile.ZipFile('dict.pickled.small.zip') as dict:
            lines = pickle.loads(dict.read(name='dict.pkl'))
            allEntries = [Entry(index=line[0], article=line[1], word=line[2], translation=line[3]) for line in lines]

            logging.debug('Found {} entries'.format(len(allEntries)))

            step = 1000
            for i in range(0, len(allEntries), step):
                start = i
                end = i + step
                if end >= len(allEntries):
                    end = len(allEntries) - 1

                logging.debug('Inserting from range {} - {}'.format(start, end))

                db.put(allEntries[start:end])
                logging.debug('Inserted range {} - {}'.format(start, end))

            self.response.out.write("Created successfully")

application = webapp2.WSGIApplication([('/init', InitializeHandler)], debug=True)