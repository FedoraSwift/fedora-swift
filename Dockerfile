# Build Swift in Docker

FROM fedora:23
MAINTAINER David Sperling <dsperling@smithmicro.com>

ENV BUILD_SCRIPT swiftbuild.sh

WORKDIR /fedora-swift

COPY *.sh *.ini ./

# remove the unnecessary sudo commands
RUN sed -i 's/sudo//g' $BUILD_SCRIPT

RUN ./$BUILD_SCRIPT setup \
  && ./$BUILD_SCRIPT update

# This command currently fails with:
# utils/build-script: fatal error: can't find clang (please install clang-3.5 or a later version)
RUN ./$BUILD_SCRIPT build

# Since swift is not compiling, run bash temporarily
CMD bash
