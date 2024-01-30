#!/bin/bash
#
#  Copyright 2023 The original authors
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#
JAVA_VERSION="21.0.2-open"
if [ ! -f "$HOME/.sdkman/bin/sdkman-init.sh" ]; then
  echo -e "Installing SDKMAN!..." >&2
  curl -s "https://get.sdkman.io" | bash
fi
source "$HOME/.sdkman/bin/sdkman-init.sh"
if [ ! -d "$HOME/.sdkman/candidates/java/$JAVA_VERSION" ]; then
    echo -e "Installing Java $JAVA_VERSION" >&2
    sdk install java $JAVA_VERSION
fi
sdk use java $JAVA_VERSION 1>&2
./mvnw package
sdk use java $JAVA_VERSION 1>&2
