#!/bin/sh
# This file has been modified from the original Hazelcast start.sh to reference the application jar.

PRG="$0"
PRGDIR=`dirname "$PRG"`
HAZELCAST_HOME=`cd "$PRGDIR/.." >/dev/null; pwd`
PID_FILE=$HAZELCAST_HOME/bin/hazelcast_instance.pid

if [ $JAVA_HOME ]
then
	echo "JAVA_HOME found at $JAVA_HOME"
	RUN_JAVA=$JAVA_HOME/bin/java
else
	echo "JAVA_HOME environment variable not available."
    RUN_JAVA=`which java 2>/dev/null`
fi

if [ -z $RUN_JAVA ]
then
    echo "JAVA could not be found in your system."
    echo "please install Java 1.6 or higher!!!"
    exit 1
fi

	echo "Path to Java : $RUN_JAVA"

#### you can enable following variables by uncommenting them

#### minimum heap size
#MIN_HEAP_SIZE=1G

#### maximum heap size
#MAX_HEAP_SIZE=3.6G


if [ "x$MIN_HEAP_SIZE" != "x" ]; then
	JAVA_OPTS="$JAVA_OPTS -Xms${MIN_HEAP_SIZE}"
fi

if [ "x$MAX_HEAP_SIZE" != "x" ]; then
	JAVA_OPTS="$JAVA_OPTS -Xmx${MAX_HEAP_SIZE}"
fi

#export CLASSPATH="$HAZELCAST_HOME/lib/hazelcast-all-3.11.jar:$HAZELCAST_HOME/user-lib:$HAZELCAST_HOME/user-lib/*"
export CLASSPATH="$HAZELCAST_HOME/lib/george.jar"
#export CLASSPATH="$HAZELCAST_HOME/lib/hazelcast-all-3.12.5.jar:$HAZELCAST_HOME/lib/george.jar"

echo "########################################"
echo "# RUN_JAVA=$RUN_JAVA"
echo "# JAVA_OPTS=$JAVA_OPTS"
echo "# starting now...."
echo "########################################"

PID=$(cat "${PID_FILE}");
if [ -z "${PID}" ]; then
    echo "Process ID for Hazelcast instance is written to location: {$PID_FILE}"
    $RUN_JAVA -server $JAVA_OPTS edu.gmu.css.hazelcast.StartHazelcastInstance &
    echo $! > ${PID_FILE}
else
    echo "Another Hazelcast instance (PID=${PID}) is already started in this folder. To start a new instance, please unzip hazelcast-3.11.zip/tar.gz in a new folder."
    exit 0
fi
