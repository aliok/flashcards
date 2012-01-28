import webapp2
from google.appengine.ext import db
import json
import datetime
from model import User
from model import Entry

setSize = 10


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