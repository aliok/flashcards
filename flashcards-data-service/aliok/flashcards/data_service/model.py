__author__ = 'ali'

from google.appengine.ext import db

class Entry(db.Model):
    index = db.IntegerProperty(required=True)
    word = db.StringProperty(required=True)
    translation = db.StringProperty(required=True, indexed=False)
    article = db.StringProperty(required=True, choices=['der', 'die', 'das'], indexed=False)

    def getAsDict(self):
        """
        Doesn't include the index, because it won't be sent to clients
        """
        return {'article': self.article, 'word': self.word, 'translation': self.translation}

class User(db.Model):
    createdOn = db.DateTimeProperty(required=True)
    lastAccessedOn = db.DateTimeProperty(required=True)
    lastEntrySet = db.IntegerProperty(required=True)
