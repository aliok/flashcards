License
===========

Copyright [2011] [Ali Ok - aliok AT apache org]

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.


Module
=============

Data provider for the application. Python + Google App Engine project.

The service responds with the words(along with articles and English translation) of a specified count (currently 100) and a user key.
If the same user key is given to the service for the next time, the service returns the next set. If no user key is passed, then it returns the first set.

I couldn't use Google App Engine's BigTable, because of its limitations (50K reads per day) for free accounts. Thus, the dictionary is a static Python code.
The _flashcards-word-set-generator_ module generates that static Python dictionary code.