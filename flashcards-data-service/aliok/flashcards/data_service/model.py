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

from google.appengine.ext import db

class Entry(db.Model):
    index = db.IntegerProperty(required=True)
    word = db.StringProperty(required=True, indexed=False)
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
