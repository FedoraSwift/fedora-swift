# fedora-swift
Installation script for Opensource Apple swift language on fedora x64 linux distribution.

## About
This script has been tested on fedora 23, and successfully installs the swift compiler and ecosystem

## Tests
The current version has one unit test failure, but this may be an existing issue in the source, i would be keen to hear from any
Ubuntu users to see if they have the same experience when building from source.

   ********************
   Testing Time: 462.04s
   ********************
   Failing Tests (1):
       Swift :: Driver/Dependencies/private-after.swift

     Expected Passes    : 1665
     Expected Failures  : 92
     Unsupported Tests  : 574
     Unexpected Failures: 1
   *** Failed while running tests for swift (check-swift-linux-x86_64)
   utils/build-script: command terminated with a non-zero exit status 1, aborting
   ~/tmp/swiftbuild/swift


## building

The build system creates a folder called ~/tmp/swiftbuild in your home directory, run the script as a normal user, it will prompt for a sudo
password if it needs it.  The setup phase installs any missing packages required using "dnf". The setup phase will download all the source from
the apple repos.

     $swiftbuild.sh setup                             # Downloads all the source and sets up a build enviroment
     $swiftbuild.sh update                            # Updates the swift source repo clones with lastest version
     $swiftbuild.sh build                             # build the compiler
     $swiftbuild.sh test                              # build and run the test suite

Note: There is a configuration option in the script "BUILDTHREADS", which sets the number of threads the build system uses.
By Default it is set to 1, I have a tried it on two machines, a 4core machine with 8G Ram and and an 8core machine with 12G Ram, and in both cases
the machines became completly unresponsive and swap bound if i took it above 2, at the end of the build pass the swift compilation system links a bunch
of executables and each link takes 2-4G of Ram.  

## Installing
Still working on the install phase, i will need to run up an ubuntu vm to see where it installs etc, and what the standard binaries are called, there are already a couple of unix tools called swift, one is a messaging client and the other is part of the openstack project.

## Hacky stuff
The swift build system was designed for Ubuntu, and refferences a directory /usr/include/x86_64-gnu-linux/ which is an alias of /usr/include, the setup phase of the swiftbuild script
installs a symlink linking this path to /usr/include, you should be aware that this creates a circular path, which could under some circumstances cause problesm.

I am considering unlinking this at the end of the script execution if the directory /usr/include/x86_64-gnu-linux/x86_64-gnu-linux exists, indicating its a child to parent symlink.  
