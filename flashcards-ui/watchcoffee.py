#! /usr/bin/env python

from subprocess import call

def watchCoffee():
    '''
    requires node.js and the CoffeeScript module for to be installed.
    '''

    call(['coffee','-o', 'static/js/', '-cw', 'coffee/'], shell=True)

if __name__ == "__main__":
    watchCoffee()