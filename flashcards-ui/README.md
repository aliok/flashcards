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

The UI part for the application. Python + Google App Engine + CofeeScript + JQueryMobile + Html5 project.

UI part interacts with the user and asks user to identify the articles for given nouns, as well as providing some more features.

Fetches the word sets from the data service and stores them on the client side using Html5 websql API. Stores the user key retrieved from the data service
and sends it during a new word set request, thus doesn't show the same word set all the time.

Shown words are tracked, in order to fetch next word set from the server when all words are shown. When all words are shown, user is asked about fetching the next word set.
If user wants study the current set again, then it doesn't fetch the next word set.

There are some small features for IOS, which allows better integration. _add2home_ is used for suggesting users to add the app to their home screen.

Html5 offline features (appcache, etc) is also used. So, the users can use the application offline on their devices.

Development
==========================

Project consists of 3 parts:

* Html: JQueryMobile templates for the UI.
* CoffeeScript : The functionality is provided with Javascript, which is translated from CoffeeScript.
* Python : Python code is only for doing some redirection ("/" -> "/index.html") on the Google App Engine environment and building the project

Building
===================

You can run `buildcoffee.py` and compile CoffeeScript into Javascript, or you can run `watchcoffee.py` and let CoffeeScript compiler watch
the changes on your resources and recompile if necessary.

Both scripts use the node.js module of CoffeeScript, so node.js and the CoffeeScript module must be installed on your system.
Compiling with portable CoffeeScript compiler is also possible, but you need to do a lot of copy-paste operations.