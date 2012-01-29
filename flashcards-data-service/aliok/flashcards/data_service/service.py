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
import json
import datetime
from aliok.flashcards.data_service import dictSet
from model import User
import logging

class DataServiceHandler(webapp2.RequestHandler):
    def getUser(self):
        userKey = self.request.get("userKey")
        if userKey:
            return User.get(userKey)
        else:
            return None

    def getEntrySetForUser(self, user):
        newEntrySetNumber = user.lastEntrySet + 1
        if newEntrySetNumber >= dictSet.dictSetCount:
            newEntrySetNumber = 0
        import_string = "from aliok.flashcards.data_service.dictSet import dictSet_{}".format(newEntrySetNumber)
        exec import_string
        entries = None
        exec 'entries = dictSet_{}'.format(newEntrySetNumber)
        return entries, newEntrySetNumber

    def get(self):
        user = self.getUser()
        now = datetime.datetime.now()

        if not user:
            user = User(createdOn=now, lastAccessedOn=now, lastEntrySet=-1)

        entries, newEntrySetNumber = self.getEntrySetForUser(user)

        user.lastEntrySet = newEntrySetNumber
        user.lastAccessedOn = now

        try:
            user.put()
            userKeyToWrite = str(user.key())
        except Exception as e:
            logging.error(str(e))
            userKeyToWrite = None

        def dictionarize(e):
            return {'a': e[0], 'w': e[1], 't': e[2]}   #to save bandwidth

        jsonifiedData = json.dumps({'userKey': userKeyToWrite, 'entries': [dictionarize(entry) for entry in entries]})

        callbackParam = self.request.get('callback')
        if callbackParam:        #if exists, then return as JSONP
            self.response.headers['Content-Type'] = 'application/javascript'
            self.response.out.write('{}({});'.format(callbackParam, jsonifiedData))
        else:
            self.response.headers['Content-Type'] = 'application/json'
            self.response.out.write(jsonifiedData)

application = webapp2.WSGIApplication([('/data', DataServiceHandler)], debug=True)