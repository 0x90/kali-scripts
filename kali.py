#!/usr/bin/env python
# -*- encoding: utf-8 -*-
# curl https://bootstrap.pypa.io/ez_setup.py | python
#
# curl http://peak.telecommunity.com/dist/ez_setup.py | python
#
# sudo curl http://peak.telecommunity.com/dist/ez_setup.py | sudo python

__author__ = '090h'
__license__ = 'GPL'

from sys import argv, exit
from os import path, geteuid
from subprocess import Popen, PIPE
from argparse import ArgumentParser, ArgumentDefaultsHelpFormatter
from datetime import datetime
from sh import apt_get

def cmd_exec(cmd):
    return Popen(cmd, shell=True).communicate()


def question(text, ):
    pass

#import tkinter as tk
#from ttk import Tk
import _tkinter as tk

#from Tkinter import *
from Tkinter import Tk, Button, Frame, Entry, END, Variable, Checkbutton
from Dialog import Dialog


class ABC(Frame):

    def __init__(self,parent=None):
        Frame.__init__(self,parent)
        self.parent = parent
        self.pack() # Pack.config(self)  # same as self.pack()
        ABC.make_widgets(self)
        Button(self, text='Pop1', command=self.dialog1).pack()
        enable = {'ID1050': 0, 'ID1106': 0, 'ID1104': 0, 'ID1102': 0}
        for machine in enable:
            enable[machine] = Variable()
            l = Checkbutton(self, text=machine, variable=enable[machine])
            l.pack()

        self.pack()


    def make_widgets(self):
        self.root = Tk()
        self.root.title("Simple Prog")

    def dialog1(self):
        ans = Dialog(self,
                     title   = 'Title!',
                     text    = 'text'
                               'and text "quotation".',
                     bitmap  = 'questhead',
                     default = 0, strings = ('Yes', 'No', 'Cancel'))



if __name__ == '__main__':
    #ABC().mainloop()
    parser = ArgumentParser(description='Kali.py by @090h', formatter_class=ArgumentDefaultsHelpFormatter)
    parser.add_argument('action', required=True, help='action to run')
    parser.add_argument('--map', dest='accumulate', action='store_const',
                   const=sum, default=max,
                   help='sum the integers (default: find the max)')

    args = parser.parse_args()
    #print args.accumulate(args.integers)
    parser.add_argument('-V', action='version', version='%(prog)s 0.1')
    args = parser.parse_args()
    start_time = datetime.now()



    print('Start time: %s' % start_time)
    print('Finish time: %s' % datetime.now())