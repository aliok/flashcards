#
# Copyright [2012] [Ali Ok - aliok@apache.org]
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
#

__author__ = 'ali'

import sys
import shutil
import os

resourceFolders = ['pages/', 'static/']
sourceFolder = '../flashcards-ui/'
destinationFolder = 'assets/www/'

def main():
    for path in resourceFolders:
        destination_folder_path = destinationFolder + path
        if os.path.exists(destination_folder_path):
            shutil.rmtree(destination_folder_path)

        shutil.copytree(sourceFolder + path, destination_folder_path)

if __name__ == "__main__":
    sys.exit(main())