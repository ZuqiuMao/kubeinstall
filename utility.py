import os
import fnmatch
import sys
import fileinput
import string
import re
import os.path
import shutil
from subprocess import call

def excuteCommand(fullCammand):
    try:
        retcode = call(fullCammand, shell=True)
        if retcode < 0:
            print >>sys.stderr, "Child was terminated by signal", -retcode
        else:
            print >>sys.stderr, "Child returned", retcode
    except OSError as e:
        print >>sys.stderr, "Execution failed:", e


def disablePatternLine(filePath, pattern):
    for i, line in enumerate(fileinput.FileInput(filePath,inplace=1)):
        bSkip = False
        if line.find(pattern) != -1 and not line.strip().startswith("#"):
            line = "#" + line 
            print (line)
        else:
            print (line)


def modifyPatternLine(filePath, pattern, lineTargetString):
    for i, line in enumerate(fileinput.FileInput(filePath,inplace=1)):
        bSkip = False
        if line.strip().startswith(pattern):
            line = lineTargetString + "\n"
            print (line)
        else:
            print (line)

def addSourceLines(filePath):
    sourceString = '''deb http://mirrors.aliyun.com/ubuntu/ trusty main restricted universe multiverse
        deb http://mirrors.aliyun.com/ubuntu/ trusty-security main restricted universe multiverse
        deb http://mirrors.aliyun.com/ubuntu/ trusty-updates main restricted universe multiverse
        deb-src http://mirrors.aliyun.com/ubuntu/ trusty main restricted universe multiverse
        deb-src http://mirrors.aliyun.com/ubuntu/ trusty-security main restricted universe multiverse
        deb-src http://mirrors.aliyun.com/ubuntu/ trusty-updates main restricted universe multiverse'''
    for i, line in enumerate(fileinput.FileInput(filePath,inplace=1)):
        bSkip = False
        if i == 0 :
            if not line.strip().startswith("deb http://mirrors.aliyun.com/ubuntu/ trusty main restricted universe multiverse"):
                line = sourceString + "\n" + line 
            print (line)
        else:
            print (line)


if __name__ == '__main__':
    addSourceLines("/etc/apt/sources.list")
    disablePatternLine("/etc/fstab", "swap")
    modifyPatternLine("/etc/sysctl.d/10-network-security.conf", "net.ipv4.conf.default.rp_filter" , "net.ipv4.conf.default.rp_filter=1")
    modifyPatternLine("/etc/sysctl.d/10-network-security.conf", "net.ipv4.conf.all.rp_filter" , "net.ipv4.conf.all.rp_filter=1")


