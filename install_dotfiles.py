#!/usr/bin/python
#  install_dotfiles
#  This script will build platform-specific dotfiles and create the appropriate symlinks in ~

import platform
import os
import sys

sysName = platform.system()
homeDir = os.path.expanduser('~') + '/'
destDir = os.path.dirname(os.path.abspath(__file__)) + '/'
bashrc = open('bashrc','a')
bashrc.write("#!/bin/bash\n")
bashrc.write("# This file was generated by a script. Do not edit manually!\n")

def cleanUp():
  os.chdir(destDir)
  print "Cleaning up existing output files in " + destDir
  for file in ['bashrc']:
    if os.path.isfile(file):
      print file
      os.remove(file)

def writeSection(fileName, allowComments):
  f = open(fileName,'r')
  for line in f:
    if line.startswith('#'):
      if allowComments:
        bashrc.write(line)
    else:
      bashrc.write(line)

def createSymlink(targetName, linkName)	:
  target = destDir + targetName
  link = homeDir +  linkName
  print "Creating symlink: " + link + " -> " + target
  if os.path.islink(link):
    print "Link exists. Removing..."
    os.remove(link)
  os.symlink(target, link)
  print "Link created."

print "System identified as " + sysName
cleanUp()
if sysName == 'Linux':
  bashrc.write("# ~/.bashrc: executed by bash(1) for non-login shells.\n")
  if os.path.isfile('bash_private'):
    writeSection('bash_private',False)
  writeSection('bash_common',False)
  writeSection('bash_linux',True)
  createSymlink('bashrc','.bashrc')
elif sysName == 'Darwin':
  bashrc.write("# ~/.bash_profile: executed by bash(1) for lon-login shells.\n")
  if os.path.isfile('bash_private'):
    writeSection('bash_private',False)
  writeSection('bash_common',False)
  writeSection('bash_mac',True)
  createSymlink('bashrc','.bash_profile')
else:
  print "System not supported!"
  bashrc.close()
  exit(1)

createSymlink('vimrc','.vimrc')
bashrc.close()

