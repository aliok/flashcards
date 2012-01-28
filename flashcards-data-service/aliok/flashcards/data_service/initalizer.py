#Copyright [2011] [Ali Ok - aliok AT apache org]
#
#Licensed under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License.
#You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
#Unless required by applicable law or agreed to in writing, software
#distributed under the License is distributed on an "AS IS" BASIS,
#WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#See the License for the specific language governing permissions and
#limitations under the License.

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