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
import json
import datetime
from model import User
from model import Entry

setSize = 100


class DataServiceHandler(webapp2.RequestHandler):
    def get(self):
        userKey = self.request.get("userKey")
        user = None
        if userKey:
            user = User.get(userKey)
        else:
            user = None

        now = datetime.datetime.now()

        if not user:
            user = User(createdOn=now, lastAccessedOn=now, lastEntrySet=-1)

        entrySetCount = Entry.all().count(limit = 100000000) / setSize

        newEntrySet = user.lastEntrySet + 1
        if newEntrySet >= entrySetCount:
            newEntrySet = 0


        min = newEntrySet * setSize
        q = db.GqlQuery("SELECT * FROM Entry WHERE index >= :min AND index <= :max", min=min, max=min + setSize)
        entries = q.fetch(setSize)

        user.lastEntrySet = newEntrySet
        user.lastAccessedOn = now

        user.put()

        self.response.out.write(json.dumps({'userKey' : str(user.key()), 'entries' : [entry.getAsDict() for entry in entries]}))


application = webapp2.WSGIApplication([('/data', DataServiceHandler)], debug=True)