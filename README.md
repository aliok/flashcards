License
===========

Copyright [2012] [Ali Ok - aliok AT apache org]

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

Project
============
A flash cards application for learning German [articles(artikel)](http://en.wikipedia.org/wiki/Article_(grammar) ).

The application is hosted on Google App Engine with this URL: [http://the-flashcards.appspot.com](http://the-flashcards.appspot.com)

Consists of 3 modules:

* flashcards-data-service : Data provider for the application. Python + Google App Engine project. 
	
	The service responds with the words(along with articles and English translation) of a specified count (currently 100) and a user key.
	If the same user key is given to the service for the next time, the service returns the next set. If no user key is passed, then it returns the first set.
	
	See the module's README for more details.
	
* flashcards-ui : The UI part for the application. Python + Google App Engine + CofeeScript + JQueryMobile + Html5 project.
	
	UI part interacts with the user and asks user to identify the articles for given nouns, as well as providing some more features.
	
	See the module's README for more details.
	
* flashcards-wordset-generator : This module generates the word sets. Python project.

	It goes through Wikipedia articles, follows links to Wikipedia articles until a certain point and determines the frequency of the words in an existing dictionary. 
	Thus, the most frequent words can be asked first.
	
	See the module's README for more details.

Give it a try
=================
The application is available on [http://the-flashcards.appspot.com](http://the-flashcards.appspot.com).

It is Android 2.2+, IOS (Iphone, Ipad etc), Chrome and Safari compatible.

The application should run perfectly on any browser that supports Html5 websql API and localstorage API.