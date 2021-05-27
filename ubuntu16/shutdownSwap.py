#!/usr/bin/python
import re

with open("/etc/fstab","r") as f_r:
    reader = f_r.readlines()
with open("/etc/fstab","w") as f_w:
    for line in reader:
        if re.search("swap",line) and line[0] != "#":
            str2list = list(line)
            str2list.insert(0,"#")
            line = ''.join(str2list)
        f_w.write(line) 
         
