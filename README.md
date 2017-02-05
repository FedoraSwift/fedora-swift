# fedora-swift
Build script for Swift language on Fedora 24 and CentOS 7 x64 Linux distribution. Note: CentOS script is still work in progress.

Note: a newer version of this script aimed at swift 3.1 and Fedora 25 is now available for testing in in https://github.com/FedoraSwift/fedora-swift2, please provide feedback in the issues section on that repo/. 

## About
This script has been tested on fedora 23, and successfully builds the swift compiler and ecosystem, it creates an install package which is in the same layout as the supplied ubuntu install tar files, but build against the fedora 23 shared libraries. 

Its also worth remembering that in the days and weeks following the release, its not unlikely that full support for Fedora is going to be implemented in the base build scripts, in fact as time goes on this script is shrinking as more and more issues that required patches and workarounds disapear. At the time of writing this im only down to one blocker. 

## Tests
The current version does not show any unit-test failures as shown below.

```
xctest-build: Performing installation into /home/thawkins/tmp/swiftbuild/package/usr/lib/swift/linux/x86_64 and /home/thawkins/tmp/swiftbuild/package/usr/lib/swift/linux
xctest-build: Done.
--- Installing foundation ---
+ pushd /home/thawkins/tmp/swiftbuild/swift-corelibs-foundation
~/tmp/swiftbuild/swift-corelibs-foundation ~/tmp/swiftbuild/swift
+ ninja install
[1/1] mkdir -p "/home/thawkins/tmp/swiftbuild/package//usr/lib/swift/linux"; cp "../build/buildbot_linux...x86_64/Foundation//usr/lib/swift/CoreFoundation" "/home/thawkins/tmp/swiftbuild/package//usr/lib/swift/"
+ popd
~/tmp/swiftbuild/swift
--- Creating installable package ---
-- Package file: /home/thawkins/tmp/swiftbuild/package/swift-linux-x86_64-fedora-2015-12-11--13:20:53.tgz --
~/Public/fedora-swift

```

## building

The build system creates a folder called ~/tmp/swiftbuild in your home directory, run the script as a normal user, it will prompt for a sudo
password if it needs it.  The setup phase installs any missing packages required using "dnf". The setup phase will download all the source from
the apple repos.

```
     $swiftbuild.sh setup                             # Downloads all the source and sets up a build environment
     $swiftbuild.sh update                            # Updates the swift source repo clones with latest version
     $swiftbuild.sh build                             # build the compiler, and create a snapshot install tar in ~/tmp/swiftbuild/package
```

Note: There is a configuration option in the script "BUILDTHREADS", which sets the number of threads the build system uses.
By Default it is set to 1, I have a tried it on two machines, a 4core machine with 8G Ram and and an 8core machine with 12G Ram, and in both cases
the machines became completely unresponsive and swap bound if i took it above 2, at the end of the build pass the swift compilation system links a bunch
of executables and each link takes 2-4G of Ram.  

## Installing

The tar file that is generated is the same layout as the ubuntu one, so just follow those instructions. 

## Hacky stuff

There is a bug in the lldb debugger build that creates the python2.7 bindings in the wrong place,  previous versions of this script required running a "patch" function, but now we avoid that by introducing a symlink into the build stage before the build is run. 

You can follow the bug here https://bugs.swift.org/browse/SR-100

## Caveats
The Swift master branch is curently under rapid change, so this script will often at times fail for reasons other than the bug above, you can update to the latest version and try and build again. 

To update and rebuild 

```
     $swiftbuild.sh update                            # pull down the latest updates to the repository
     $swiftbuild.sh build                             # build the compiler, IT WILL fail with an error about the python2.7 directory being missing. 
```

Once we get to a stable branch that builds on F23, I will switch the script to checking out that version instead of the wildly unstable 'master' branch. 
