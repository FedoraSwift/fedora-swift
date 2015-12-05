# fedora-swift
Build script for Open-source Apple swift language on fedora 23 x64 Linux distribution.

## About
This script has been tested on fedora 23, and successfully builds the swift compiler and ecosystem, it does not currently have support for installing the swift compiler,
that is something I'm working on right now. I am publishing this code now in the hope of attracting some help as I'm not completely familiar with working with these topics.

Its also worth remembering that in the days and weeks following the release, its not unlikely that full support for Fedora is not going to be implemented in the base build scripts.

## Tests
The current version has one unit test failure, but this may be an existing issue in the source, i would be keen to hear from any
Ubuntu users to see if they have the same experience when building from source.

```
[100%] Running Swift tests for x86_64-unknown-linux-gnu
lit.py: lit.cfg:204: note: using swift: /home/thawkins/tmp/swiftbuild/build/Unix_Makefiles-ReleaseAssert/swift-linux-x86_64/bin/swift
lit.py: lit.cfg:204: note: using swiftc: /home/thawkins/tmp/swiftbuild/build/Unix_Makefiles-ReleaseAssert/swift-linux-x86_64/bin/swiftc
lit.py: lit.cfg:204: note: using swift-autolink-extract: /home/thawkins/tmp/swiftbuild/build/Unix_Makefiles-ReleaseAssert/swift-linux-x86_64/bin/swift-autolink-extract
lit.py: lit.cfg:204: note: using sil-opt: /home/thawkins/tmp/swiftbuild/build/Unix_Makefiles-ReleaseAssert/swift-linux-x86_64/bin/sil-opt
lit.py: lit.cfg:204: note: using sil-extract: /home/thawkins/tmp/swiftbuild/build/Unix_Makefiles-ReleaseAssert/swift-linux-x86_64/bin/sil-extract
lit.py: lit.cfg:204: note: using lldb-moduleimport-test: /home/thawkins/tmp/swiftbuild/build/Unix_Makefiles-ReleaseAssert/swift-linux-x86_64/bin/lldb-moduleimport-test
lit.py: lit.cfg:204: note: using swift-ide-test: /home/thawkins/tmp/swiftbuild/build/Unix_Makefiles-ReleaseAssert/swift-linux-x86_64/bin/swift-ide-test
lit.py: lit.cfg:204: note: using clang: /home/thawkins/tmp/swiftbuild/build/Unix_Makefiles-ReleaseAssert/llvm-linux-x86_64/bin/clang
lit.py: lit.cfg:204: note: using llvm-link: /home/thawkins/tmp/swiftbuild/build/Unix_Makefiles-ReleaseAssert/llvm-linux-x86_64/bin/llvm-link
lit.py: lit.cfg:204: note: using swift-llvm-opt: /home/thawkins/tmp/swiftbuild/build/Unix_Makefiles-ReleaseAssert/swift-linux-x86_64/bin/swift-llvm-opt
lit.py: lit.cfg:248: note: Using resource dir: /home/thawkins/tmp/swiftbuild/build/Unix_Makefiles-ReleaseAssert/swift-linux-x86_64/lib/swift
lit.py: lit.cfg:274: note: Using Clang module cache: /tmp/swift-testsuite-clang-module-cache2Yvbzt
lit.py: lit.cfg:278: note: Using code completion cache: /tmp/swift-testsuite-completion-cacheYM3iTq
lit.py: lit.cfg:616: note: Testing Linux x86_64-unknown-linux-gnu
lit.py: lit.cfg:204: note: using swift-autolink-extract: /home/thawkins/tmp/swiftbuild/build/Unix_Makefiles-ReleaseAssert/swift-linux-x86_64/bin/swift-autolink-extract
lit.py: lit.cfg:752: note: Using platform module dir: /home/thawkins/tmp/swiftbuild/build/Unix_Makefiles-ReleaseAssert/swift-linux-x86_64/lib/swift/%target-sdk-name/x86_64
Testing Time: 120.68s
Expected Passes    : 1668
Expected Failures  : 92
Unsupported Tests  : 574
[100%] Built target check-swift-linux-x86_64
-- check-swift-linux-x86_64 finished --
--- Finished tests for swift ---
~/Public/fedora-swift
```

## building

The build system creates a folder called ~/tmp/swiftbuild in your home directory, run the script as a normal user, it will prompt for a sudo
password if it needs it.  The setup phase installs any missing packages required using "dnf". The setup phase will download all the source from
the apple repos.

```
     $swiftbuild.sh setup                             # Downloads all the source and sets up a build environment
     $swiftbuild.sh update                            # Updates the swift source repo clones with latest version
     $swiftbuild.sh build                             # build the compiler
     $swiftbuild.sh test                              # build and run the test suite
```

Note: There is a configuration option in the script "BUILDTHREADS", which sets the number of threads the build system uses.
By Default it is set to 1, I have a tried it on two machines, a 4core machine with 8G Ram and and an 8core machine with 12G Ram, and in both cases
the machines became completely unresponsive and swap bound if i took it above 2, at the end of the build pass the swift compilation system links a bunch
of executables and each link takes 2-4G of Ram.  

The script currently builds with release config using Unix Make files, as i found that to be less intense on my hardware than the ninja-build system.

## Installing
Still working on the install phase, i will need to run up an Ubuntu VM to see where it installs etc, and what the standard binaries are called, there are already a couple of UNIX tools called swift, one is a messaging client and the other is part of the openstack project.

## Hacky stuff
The swift build system was designed for Ubuntu, and references a directory /usr/include/x86_64-gnu-linux/ which is an alias of /usr/include, the setup phase of the swiftbuild script
installs a symlink linking this path to /usr/include, you should be aware that this creates a circular path, which could under some circumstances cause problems.

I am considering unlinking this at the end of the script execution if the directory /usr/include/x86_64-gnu-linux/x86_64-gnu-linux exists, indicating its a child to parent symlink.  
