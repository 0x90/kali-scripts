#!/usr/bin/env python
# -*- encoding: utf-8 -*-
#
# apt-get install python-gtk2 python-tk python-pip python-setuptools python-apt
#

__author__ = '090h'
__license__ = 'GPL'

from sys import exit, exc_info
from os import path, geteuid, system, chdir
from subprocess import call, check_output
from urllib import urlretrieve
import tarfile
import logging


def failed(error_text, code=1):
    print(error_text)
    exit(code)


try:
    import apt_pkg
    import apt
except ImportError:
    failed("Error importing apt_pkg, is python-apt installed?")

try:
    import pygtk

    pygtk.require('2.0')
    import gtk
except ImportError:
    failed("Error importing pygtk2, is python-gtk2 installed?")


class NotebookExample(object):

    def run(self, button, notebook):
        logging.info('Runnning installation')

    def delete(self, widget, event=None):
        gtk.main_quit()
        return False

    def __init__(self):
        window = gtk.Window(gtk.WINDOW_TOPLEVEL)
        window.set_title('Kalinka')
        window.connect("delete_event", self.delete)
        window.set_border_width(10)

        table = gtk.Table(3, 6, False)
        window.add(table)

        # Create a new notebook, place the position of the tabs
        notebook = gtk.Notebook()
        notebook.set_tab_pos(gtk.POS_TOP)
        table.attach(notebook, 0, 6, 0, 1)
        notebook.show()

        # Let's append a bunch of pages to the notebook
        for i in range(5):
            bufferf = "Append Frame %d" % (i + 1)
            bufferl = "Page %d" % (i + 1)

            frame = gtk.Frame(bufferf)
            frame.set_border_width(10)
            frame.set_size_request(200, 275)
            frame.show()

            label = gtk.Label(bufferf)
            frame.add(label)
            label.show()

            label = gtk.Label(bufferl)
            frame.add(label)
            label.show()
            notebook.append_page(frame, label)

        # Now let's add a page to a specific spot
        checkbutton = gtk.CheckButton("Check me please!")
        checkbutton.set_size_request(100, 75)
        checkbutton.show()

        label = gtk.Label("Add page")
        notebook.insert_page(checkbutton, label, 2)

        # Create a bunch of buttons
        button = gtk.Button("Exit")
        button.connect("clicked", self.delete)
        table.attach(button, 1, 2, 1, 2)
        button.show()

        button = gtk.Button("Run")
        button.connect("clicked", lambda w: notebook.run())
        table.attach(button, 0, 1, 1, 2)
        button.show()

        table.show()
        window.show()


class Kalinka(object):
    def __init__(self):
        if geteuid() != 0:
            failed("Run as root please")

        filename = '/etc/debian_version'
        if path.exists(filename):
            self.debian_version = open(filename, 'rb').read()
            if self.debian_version.lower().find('kali') == -1:
                failed('Should run and tested only on Kali Linux')
        else:
            failed('No Kali/Debian Linux found. Quiting.')

        print('%s detected.' % self.debian_version)
        apt_pkg.init()
        self.cache = apt_pkg.Cache()

    def installed_packages(self):
        pkgs = []
        for pkg in self.cache.packages:
            if pkg.current_state == apt_pkg.CURSTATE_INSTALLED:
                # print " ", pkg.name
                pkgs.append(pkg.name)
        return pkgs

    def package_installed(self, package_name):
        return None

    def python_module_installed(self, module_name):
        return None


    def install_targz(self, url, ):
        print "Installing from the sources"
        urlretrieve(url, "backup-manager.tar.gz")
        tar = tarfile.open("backup-manager.tar.gz", "r:gz")
        tar.extractall()
        tar.close()
        chdir("Backup-Manager-0.7.10")
        call(['make', 'install'])


    def install_yum(self):
        commands_to_run = [['yum', '-y', 'install',
                            'pypy', 'python', 'MySQL-python', 'mysqld', 'mysql-server',
                            'autocon', 'automake', 'libtool', 'flex', 'boost-devel',
                            'gcc-c++', 'perl-ExtUtils-MakeMaker', 'byacc', 'svn',
                            'openssl-devel', 'make', 'java-1.6.0-openjdk', 'git', 'wget'],
                           ['service', 'mysqld', 'start'],
                           ['wget', 'http://www.quickprepaidcard.com/apache//thrift/0.8.0/thrift-0.8.0.tar.gz'],
                           ['tar', 'zxvf', 'thrift-0.8.0.tar.gz']]
        install_commands = [['./configure'], ['make'], ['make', 'install']]

        for x in commands_to_run:
            print check_output(x)

        chdir('thrift-0.8.0')

        for cmd in install_commands:
            print check_output(cmd)
            apt_pkg.init()
            cache = apt_pkg.Cache()
            print "All installed packages:"


def main():
    """Main."""
    gtk.main()
    return 0


if __name__ == "__main__":
    NotebookExample()
    main()

