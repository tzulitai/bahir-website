#!/usr/bin/env bash
#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to you under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

##############################################################################
# This script generates the documentation for the individual Bahir modules   #
# from the README.md files found in the modules in the Bahir source repo     #
#                                                                            #
#    bahir (source repo)       bahir-website                                 #
#    .                         └─site                                        #
#    .                           └─docs                                      #
#    .                             └─spark                                   #
#    ├─sql-streaming-mqtt            └─current                               #
#    │ └─README.md          ─────>     ├─spark-sql-streaming-mqtt.md         #
#    ├─streaming-akka                  │                                     #
#    │ └─README.md          ─────>     ├─spark-streaming-akka.md             #
#    ├─streaming-mqtt                  │                                     #
#    │ └─README.md          ─────>     ├─spark-streaming-mqtt.md             #
#    ├─streaming-twitter               │                                     #
#    │ └─README.md          ─────>     ├─spark-streaming-twitter.md          #
#    └─streaming-zeromq                │                                     #
#      └─README.md          ─────>     └─spark-streaming-zeromq.md           #
#                                                                            #
# Page header with license text comes from the respective template files     #
# under site/docs/spark/templates                                            #
##############################################################################


set -e

BASE_DIR=$(pwd)
WEBSITE_TEMPLATES_DIR=$BASE_DIR/site/docs/spark/templates
WEBSITE_DOC_DIR=$BASE_DIR/site/docs/spark/current
BAHIR_SOURCE_DIR=$BASE_DIR/target/bahir

function checkout_code {
    # Checkout code
    rm -rf target
    mkdir target
    cd target
    git clone https://git-wip-us.apache.org/repos/asf/bahir.git --quiet
    cd bahir
    git checkout $GIT_REF
    git_hash=`git rev-parse --short HEAD`
    echo "Checked out Bahir git hash $git_hash"

    git clean -d -f -x

    cd "$BASE_DIR" #return to base dir
}

checkout_code

rm  -rf $WEBSITE_DOC_DIR/spark*.md

cp  $WEBSITE_TEMPLATES_DIR/spark-sql-streaming-mqtt.template $WEBSITE_DOC_DIR/spark-sql-streaming-mqtt.md
cat $BAHIR_SOURCE_DIR/sql-streaming-mqtt/README.md        >> $WEBSITE_DOC_DIR/spark-sql-streaming-mqtt.md

cp  $WEBSITE_TEMPLATES_DIR/spark-streaming-akka.template $WEBSITE_DOC_DIR/spark-streaming-akka.md
cat $BAHIR_SOURCE_DIR/streaming-akka/README.md        >> $WEBSITE_DOC_DIR/spark-streaming-akka.md

cp  $WEBSITE_TEMPLATES_DIR/spark-streaming-mqtt.template $WEBSITE_DOC_DIR/spark-streaming-mqtt.md
cat $BAHIR_SOURCE_DIR/streaming-mqtt/README.md        >> $WEBSITE_DOC_DIR/spark-streaming-mqtt.md

cp  $WEBSITE_TEMPLATES_DIR/spark-streaming-twitter.template $WEBSITE_DOC_DIR/spark-streaming-twitter.md
cat $BAHIR_SOURCE_DIR/streaming-twitter/README.md        >> $WEBSITE_DOC_DIR/spark-streaming-twitter.md

cp  $WEBSITE_TEMPLATES_DIR/spark-streaming-zeromq.template $WEBSITE_DOC_DIR/spark-streaming-zeromq.md
cat $BAHIR_SOURCE_DIR/streaming-zeromq/README.md        >> $WEBSITE_DOC_DIR/spark-streaming-zeromq.md

set +e

echo "Done."

if grep -q -r "[0-9]-SNAPSHOT" $WEBSITE_DOC_DIR/spark*.md ; then
  echo
  echo "TODO: Replace '...-SNAPSHOT' version strings:"
  echo
  grep -r -n "[0-9]-SNAPSHOT" $WEBSITE_DOC_DIR/spark*.md | sed -e 's|'$(pwd)/'||g' | grep --color "[0-9.]*-SNAPSHOT"
  echo
  echo "i.e. to replace '2.1.0-SNAPSHOT' with '2.0.2' run the following command:"
  echo
  echo "  perl -i -pe 's/2.1.0-SNAPSHOT/2.0.2/g' $WEBSITE_DOC_DIR/spark*.md"
  echo
else
  echo
  echo "Generated files:"
  echo
  ls $WEBSITE_DOC_DIR/spark*.md | xargs -n1 | sed -e 's|'$(pwd -P)/'||g'
fi
