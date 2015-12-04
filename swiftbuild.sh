#!/bin/sh
BUILDROOT=~/tmp/swiftbuild
declare -a SWIFTREPOS=("swift.git swift" "swift-llvm.git llvm" "swift-clang.git clang" "swift-lldb.git lldb" "swift-cmark.git cmark" "swift-llbuild.git llbuild" "swift-package-manager.git swiftpm" "swift-corelibs-xctest.git swift-corelibs-xctest"  "swift-corelibs-foundation.git swift-corelibs-foundation")
SWIFTREPOSBASE="git@github.com:apple"
BUILDTHREADS=1

if [ $# -lt 1 ]
then
        echo "Usage : $0 [setup|update|build|test]"
        exit
fi

case "$1" in

"setup" )  echo "Setup build enviroment"
sudo dnf install -y \
    git \
    cmake \
    ninja-build \
    clang \
    uuid-devel \
    libuuid-devel \
    icu \
    libicu \
    libicu-devel \
    libbsd-devel \
    libedit-devel \
    libxml2-devel \
    libsqlite3x-devel \
    swig \
    python-libs \
    ncurses-devel \
    python-pkgconfig


    #fix the missing libc6 references
    pushd /usr/include
      sudo ln -s . x86_64-linux-gnu
    popd

    # Make sure the build root directory is present.

    mkdir -p ~/tmp/swiftbuild
    pushd $BUILDROOT
    for repo in "${SWIFTREPOS[@]}"; do
    repodir=$BUILDROOT/`echo $repo | cut -d " " -f 2`
    	if [ ! -d "$repodir" ] ; then
    		git clone $SWIFTREPOSBASE/$repo
    	fi
    done



    if [ ! -d ~/tmp/swiftbuild/ninja ] ; then
    	git clone git@github.com:martine/ninja.git
    fi

    popd

    ;;

"update" )  echo  "updating repositories"

for repo in "${SWIFTREPOS[@]}"; do
repodir=$BUILDROOT/`echo $repo | cut -d " " -f 2`
  if [ ! -d "$repodir" ] ; then
    pushd $repodir
      git pull
    popd
  fi
done

if [ ! -d ~/tmp/swiftbuild/ninja ] ; then
  pushd ~/tmp/swiftbuild/ninja
    git pull
  popd
fi

popd

    ;;
"build" )  echo  "building swift"
    pushd $BUILDROOT/swift
      utils/build-script -- --build-args="-j $BUILDTHREADS"
    popd
   ;;
"test" )  echo  "running tests"
    pushd $BUILDROOT/swift
      utils/build-script -t -- --build-args="-j $BUILDTHREADS"
    popd
    ;;

*) echo "Unrecognised command: $1"
   ;;
esac

