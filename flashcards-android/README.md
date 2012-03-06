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

The Android application for the project. Html5 + Phonegap project.

The UI code of module `flashcards-ui` is copied into the `assets/www` folder and they're embedded in an Android Webview using Phonegap.

Available in the Android market.

Building
=============

Please note that, the `flashcards-ui` module should be built before building this application.

* Execute `fetchResources.py` script : It will copy the resources to be embedded to `assets/www` folder
* Run `ant build.xml`