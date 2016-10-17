#!/bin/sh
BUILDROOT=~/tmp/swiftbuild
declare -a SWIFTREPOS=(\
        "https://github.com/apple/swift.git swift" \
        "https://github.com/apple/swift-llvm.git llvm" \
        "https://github.com/apple/swift-clang.git clang" \
        "https://github.com/apple/swift-lldb.git lldb" \
        "https://github.com/apple/swift-cmark.git cmark" \
        "https://github.com/apple/swift-llbuild.git llbuild" \
        "https://github.com/apple/swift-package-manager.git swiftpm" \
        "https://github.com/apple/swift-corelibs-xctest.git swift-corelibs-xctest"  \
        "https://github.com/apple/swift-corelibs-foundation.git swift-corelibs-foundation"\
	"https://github.com/apple/swift-corelibs-libdispatch.git swift-corelibs-libdispatch"\
        )
BUILDTHREADS=2
NOW=`date +%Y-%m-%d--%H:%M:%S`

THISDIR="`dirname \"$0\"`"              # relative
THISDIR="`( pushd \"$THISDIR\" >/dev/null && pwd )`"  # absolutized and normalized
if [ -z "$THISDIR" ] ; then
  # error; for some reason, the path is not accessible
  # to the script (e.g. permissions re-evaled after suid)
  exit 1  # fail
fi

if [ $# -lt 1 ]
then
  echo "Usage : $0 [reset|clean|setup|update|build]"
  exit
fi

case "$1" in

  "reset" )  echo "reset build enviroment"
    rm -rf $BUILDROOT
    mkdir -p $BUILDROOT
    mkdir -p $BUILDROOT/package
    mkdir -p $BUILDROOT/symroot
    mkdir -p $BUILDROOT/build
    
    echo "reset done"
  ;;


  "setup" )  echo "Setup build enviroment"

    #install epel-release, wget
    sudo yum -y install epel-release wget

    #get updated packages from Fedora
    wget https://dl.fedoraproject.org/pub/fedora/linux/releases/24/Everything/x86_64/os/Packages/b/binutils-2.26-18.fc24.x86_64.rpm
    wget https://dl.fedoraproject.org/pub/fedora/linux/releases/24/Everything/x86_64/os/Packages/c/clang-3.8.0-1.fc24.x86_64.rpm
    wget https://dl.fedoraproject.org/pub/fedora/linux/releases/24/Everything/x86_64/os/Packages/c/clang-devel-3.8.0-1.fc24.x86_64.rpm
    wget https://dl.fedoraproject.org/pub/fedora/linux/releases/24/Everything/x86_64/os/Packages/c/clang-libs-3.8.0-1.fc24.x86_64.rpm
    wget https://dl.fedoraproject.org/pub/fedora/linux/releases/24/Everything/x86_64/os/Packages/c/cpp-6.1.1-2.fc24.x86_64.rpm
    wget https://dl.fedoraproject.org/pub/fedora/linux/releases/24/Everything/x86_64/os/Packages/g/gcc-6.1.1-2.fc24.x86_64.rpm
    wget https://dl.fedoraproject.org/pub/fedora/linux/releases/24/Everything/x86_64/os/Packages/g/gcc-c++-6.1.1-2.fc24.x86_64.rpm
    wget https://dl.fedoraproject.org/pub/fedora/linux/releases/24/Everything/x86_64/os/Packages/g/glibc-2.23.1-7.fc24.i686.rpm
    wget https://dl.fedoraproject.org/pub/fedora/linux/releases/24/Everything/x86_64/os/Packages/g/glibc-2.23.1-7.fc24.x86_64.rpm
    wget https://dl.fedoraproject.org/pub/fedora/linux/releases/24/Everything/x86_64/os/Packages/g/glibc-all-langpacks-2.23.1-7.fc24.x86_64.rpm
    wget https://dl.fedoraproject.org/pub/fedora/linux/releases/24/Everything/x86_64/os/Packages/g/glibc-common-2.23.1-7.fc24.x86_64.rpm
    wget https://dl.fedoraproject.org/pub/fedora/linux/releases/24/Everything/x86_64/os/Packages/g/glibc-devel-2.23.1-7.fc24.x86_64.rpm
    wget https://dl.fedoraproject.org/pub/fedora/linux/releases/24/Everything/x86_64/os/Packages/g/glibc-headers-2.23.1-7.fc24.x86_64.rpm
    wget https://dl.fedoraproject.org/pub/fedora/linux/releases/24/Everything/x86_64/os/Packages/i/isl-0.14-5.fc24.x86_64.rpm
    wget https://dl.fedoraproject.org/pub/fedora/linux/releases/24/Everything/x86_64/os/Packages/l/libgcc-6.1.1-2.fc24.x86_64.rpm
    wget https://dl.fedoraproject.org/pub/fedora/linux/releases/24/Everything/x86_64/os/Packages/l/libgomp-6.1.1-2.fc24.x86_64.rpm
    wget https://dl.fedoraproject.org/pub/fedora/linux/releases/24/Everything/x86_64/os/Packages/l/libmpc-1.0.2-5.fc24.x86_64.rpm
    wget https://dl.fedoraproject.org/pub/fedora/linux/releases/24/Everything/x86_64/os/Packages/l/libstdc++-6.1.1-2.fc24.x86_64.rpm
    wget https://dl.fedoraproject.org/pub/fedora/linux/releases/24/Everything/x86_64/os/Packages/l/libstdc++-devel-6.1.1-2.fc24.x86_64.rpm
    wget https://dl.fedoraproject.org/pub/fedora/linux/releases/24/Everything/x86_64/os/Packages/l/llvm-3.8.0-1.fc24.x86_64.rpm
    wget https://dl.fedoraproject.org/pub/fedora/linux/releases/24/Everything/x86_64/os/Packages/l/llvm-devel-3.8.0-1.fc24.x86_64.rpm
    wget https://dl.fedoraproject.org/pub/fedora/linux/releases/24/Everything/x86_64/os/Packages/l/llvm-libs-3.8.0-1.fc24.x86_64.rpm
    wget https://dl.fedoraproject.org/pub/fedora/linux/releases/24/Everything/x86_64/os/Packages/m/mpfr-3.1.4-1.fc24.x86_64.rpm

    #install binutils
    sudo yum install -y binutils-2.26-18.fc24.x86_64.rpm

    #install development tools
    sudo yum install -y clang-3.8.0-1.fc24.x86_64.rpm \
    clang-devel-3.8.0-1.fc24.x86_64.rpm \
    clang-libs-3.8.0-1.fc24.x86_64.rpm \
    cpp-6.1.1-2.fc24.x86_64.rpm \
    gcc-6.1.1-2.fc24.x86_64.rpm \
    gcc-c++-6.1.1-2.fc24.x86_64.rpm \
    glibc-2.23.1-7.fc24.i686.rpm \
    glibc-2.23.1-7.fc24.x86_64.rpm \
    glibc-all-langpacks-2.23.1-7.fc24.x86_64.rpm \
    glibc-common-2.23.1-7.fc24.x86_64.rpm \
    glibc-devel-2.23.1-7.fc24.x86_64.rpm \
    glibc-headers-2.23.1-7.fc24.x86_64.rpm \
    isl-0.14-5.fc24.x86_64.rpm \
    libgcc-6.1.1-2.fc24.x86_64.rpm \
    libgomp-6.1.1-2.fc24.x86_64.rpm \
    libmpc-1.0.2-5.fc24.x86_64.rpm \
    libstdc++-6.1.1-2.fc24.x86_64.rpm \
    libstdc++-devel-6.1.1-2.fc24.x86_64.rpm \
    llvm-3.8.0-1.fc24.x86_64.rpm \
    llvm-devel-3.8.0-1.fc24.x86_64.rpm \
    llvm-libs-3.8.0-1.fc24.x86_64.rpm \
    mpfr-3.1.4-1.fc24.x86_64.rpm

    #install other required packages
    sudo yum install -y \
    git \
    cmake \
    cmake3 \
    ninja-build \
    re2c \
    uuid-devel \
    libuuid-devel \
    icu \
    libicu \
    libicu-devel \
    libbsd-devel \
    libedit-devel \
    libxml2-devel \
    sqlite-devel \
    swig \
    python-libs \
    ncurses-devel \
    python-devel \
    pkgconfig

    #substitute cmake3 for cmake
    sudo mv /usr/bin/cmake /usr/bin/cmake2
    sudo ln -s /usr/bin/cmake3 /usr/bin/cmake

    #substitute ld.gold for ld
    sudo rm /etc/alternatives/ld
    sudo ln -s /usr/bin/ld.gold /etc/alternatives/ld

    #fix the missing libc6 references
    #pushd /usr/include
    #	sudo ln -s . x86_64-linux-gnu
    #popd

    # Make sure the build root directory is present.

    mkdir -p $BUILDROOT
    mkdir -p $BUILDROOT/package
    mkdir -p $BUILDROOT/symroot
    mkdir -p $BUILDROOT/build

    pushd $BUILDROOT
    for repo in "${SWIFTREPOS[@]}"; do
      repodir=$BUILDROOT/`echo $repo | cut -d " " -f 2`
      if [ ! -d "$repodir" ] ; then
        git clone $repo
      fi
    done


    if [ ! -d ~/tmp/swiftbuild/ninja ] ; then
      git clone https://github.com/martine/ninja.git
    fi

    if [ ! -f /usr/bin/ninja ] ; then
         if [ -f /usr/bin/ninja-build ] ; then
            sudo ln -s /usr/bin/ninja-build /usr/bin/ninja
         fi
    fi

    popd

  ;;

  "update" )  echo  "updating repositories"

  mkdir -p $BUILDROOT
  mkdir -p $BUILDROOT/package
  mkdir -p $BUILDROOT/symroot
  mkdir -p $BUILDROOT/build


    for repo in "${SWIFTREPOS[@]}"; do
      repodir=$BUILDROOT/`echo $repo | cut -d " " -f 2`
      if [  -d "$repodir" ] ; then
        pushd $repodir
        git pull
        popd
      fi
    done

    if [ -d ~/tmp/swiftbuild/ninja ] ; then
      pushd ~/tmp/swiftbuild/ninja
      git pull
      popd
    fi

  mkdir -p $BUILDROOT/build/buildbot_linux/lldb-linux-x86_64/lib
  mkdir -p $BUILDROOT/build/buildbot_linux/lldb-linux-x86_64/lib64/python2.7

  if [ ! -d $BUILDROOT/build/buildbot_linux/lldb-linux-x86_64/lib/python2.7 ] ; then
    if [ -d $BUILDROOT/build/buildbot_linux/lldb-linux-x86_64/lib64/python2.7 ] ; then
      ln -s $BUILDROOT/build/buildbot_linux/lldb-linux-x86_64/lib64/python2.7 $BUILDROOT/build/buildbot_linux/lldb-linux-x86_64/lib/python2.7
    fi
  fi


  ;;

  "clean" )  echo  "clean build"
  mkdir -p $BUILDROOT
  mkdir -p $BUILDROOT/package
  mkdir -p $BUILDROOT/symroot
  mkdir -p $BUILDROOT/build
  rm -rf $BUILDROOT/build/*
  rm -rf $BUILDROOT/package/*
  rm -rf $BUILDROOT/symroot/*
  ;;

  "build" )  echo  "build"
  mkdir -p $BUILDROOT
  mkdir -p $BUILDROOT/package
  mkdir -p $BUILDROOT/symroot

  if [ -f  "$BUILDROOT/package/swift-linux-x86_64-fedora-$NOW.tgz" ] ; then
    rm "$BUILDROOT/package/swift-linux-x86_64-fedora-$NOW.tgz"
  fi

  mkdir -p $BUILDROOT/build/buildbot_linux/lldb-linux-x86_64/lib
  mkdir -p $BUILDROOT/build/buildbot_linux/lldb-linux-x86_64/lib64/python2.7

  if [ ! -d $BUILDROOT/build/buildbot_linux/lldb-linux-x86_64/lib/python2.7 ] ; then
    if [ -d $BUILDROOT/build/buildbot_linux/lldb-linux-x86_64/lib64/python2.7 ] ; then
      ln -s $BUILDROOT/build/buildbot_linux/lldb-linux-x86_64/lib64/python2.7 $BUILDROOT/build/buildbot_linux/lldb-linux-x86_64/lib/python2.7
    fi
  fi

  pushd $BUILDROOT/swift
    utils/build-script --preset-file=$THISDIR/linuxpreset.ini \
      --preset=buildbot_linux_build_fedora23 \
      install_destdir="$BUILDROOT/package" \
      install_symroot="$BUILDROOT/symroot" \
      installable_package="$BUILDROOT/package/swift-linux-x86_64-fedora-$NOW.tgz" \
      build_threads=$BUILDTHREADS
  popd
  ;;

"patch" )  echo  "patch"
  mkdir -p $BUILDROOT
  mkdir -p $BUILDROOT/package
  mkdir -p $BUILDROOT/symroot

  if [ -f  "$BUILDROOT/package/swift-linux-x86_64-fedora-$NOW.tgz" ] ; then
    rm "$BUILDROOT/package/swift-linux-x86_64-fedora-$NOW.tgz"
  fi

  mkdir -p $BUILDROOT/build/buildbot_linux/lldb-linux-x86_64/lib
  mkdir -p $BUILDROOT/build/buildbot_linux/lldb-linux-x86_64/lib64/python2.7

  if [ ! -d $BUILDROOT/build/buildbot_linux/lldb-linux-x86_64/lib/python2.7 ] ; then 
    if [ -d $BUILDROOT/build/buildbot_linux/lldb-linux-x86_64/lib64/python2.7 ] ; then
      ln -s $BUILDROOT/build/buildbot_linux/lldb-linux-x86_64/lib64/python2.7 $BUILDROOT/build/buildbot_linux/lldb-linux-x86_64/lib/python2.7
    fi
  fi
  echo "patched ";
  ;;

  *) echo "Unrecognised command: $1"
  ;;
esac
