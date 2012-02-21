#!/usr/bin/env python

#
# Matthew's archive sparseimage management script
#
# Matthew Woitaszek <matthew.woitaszek@gmail.com>
# January 2012
#

# I keep a directory of archive sparseimages with names like:
#
#    Title_yyyymmdd[db]_md5sum.sparseimage
#
# Over time, as I make changes inside these images, the md5sum gets removed.
#
# This script loops over all of the sparseimages in the current directory,
# calculates the md5sum, and if the md5sum has changed, updates the filename.
#

import sys
import os
import hashlib
import datetime

# Get the current operational path
pwd = os.path.abspath(os.getcwd())
print "Scanning %s..." % (pwd)

# Process every .sparseimage file
for filename in os.listdir(pwd):
    
    # Skip files that aren't sparse images
    if not filename.endswith(".sparseimage"):
        continue
    
    fullpath = os.path.join(pwd, filename)
    title = None
    old_datestr = None
    old_md5sum = None
    
    # Get the title and old mdsum
    splits = filename[:-12].split("_")
    title = splits[0]
    if len(splits) > 2:
        old_datestr = splits[1]
        old_md5sum = splits[2]
        
    print "Found file:    %s" % (filename)
    print "   Title:      %s" % (title)
    print "   Old date:   %s" % (old_datestr)
    print "   Old md5sum: %s" % (old_md5sum)
    
    # Skip volumes that are open (this depends on the volume name being the title)
    volumes = os.listdir("/Volumes")
    if title in volumes:
        print "** This volume is open, skipping."
        print
        continue
    
    # Calcuate the md5sum
    # http://stackoverflow.com/questions/1131220/get-md5-hash-of-a-files-without-open-it-in-python
    f = open(filename, "rb")
    md5 = hashlib.md5()
    mb_count = 0
    sys.stdout.write("   Calculating")
    sys.stdout.flush()
    while True:
        # Read and accumulate the data
        data = f.read(1048576) # n*MB chunks
        if not data:
            break
        md5.update(data)
        
        # Print a . every 1GB
        mb_count = mb_count + 1
        if mb_count == 1024:
            sys.stdout.write(".")
            sys.stdout.flush()
            count = 0
    print
    
    new_md5sum = md5.hexdigest()
    f.close()
    print "   New md5sum: %s" % (new_md5sum)
    
    if old_md5sum == new_md5sum:
        print "   No changes"
        print
        continue
    
    # The file changed, rename it
    new_datestr = datetime.datetime.now().strftime("%Y%m%d")
    print "   New date:   %s" % (new_datestr)
    new_filename = "%s_%s_%s.sparseimage" % (title, new_datestr, new_md5sum)
    print "   Renaming:   %s" % (new_filename)
    os.rename(filename, new_filename)
    
    print
    



