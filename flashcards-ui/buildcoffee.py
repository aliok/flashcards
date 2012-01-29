#! /usr/bin/env python

from subprocess import call

def buildCoffee():
    '''
    requires node.js and the CoffeeScript module for to be installed.
    '''

    call(['coffee', '--compile', '--output', 'static/js/', 'coffee/'], shell=True)

if __name__ == "__main__":
    buildCoffee()