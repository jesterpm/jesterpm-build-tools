#!/bin/bash

CASSANDRA_VERSION="1.2.9"

PASSWORD=$1

if [ -e $HOME/opt/cassandra ]; then
    echo "Cassandra appears to already be installed at $HOME/opt/cassandra Skipping install..."

    if !(pgrep CassandraDaemon > /dev/null); then
        echo "Starting Cassandra..."
        $HOME/opt/cassandra/bin/start-cassandra.sh
    fi
    exit 1
fi

# Download
mkdir -p $HOME/opt
cd $HOME/opt
wget http://www.eng.lsu.edu/mirrors/apache/cassandra/${CASSANDRA_VERSION}/apache-cassandra-${CASSANDRA_VERSION}-bin.tar.gz

tar xzf apache-cassandra-${CASSANDRA_VERSION}-bin.tar.gz
rm apache-cassandra-${CASSANDRA_VERSION}-bin.tar.gz
ln -s apache-cassandra-${CASSANDRA_VERSION} cassandra

mkdir -p cassandra/var/data cassandra/var/log

# Configuration
CONFIG_FILE=cassandra/conf/cassandra.yaml

sed -i "s/cluster_name: 'Test Cluster'/cluster_name: 'Dev Cluster'/" $CONFIG_FILE
sed -i "s|/var/lib/cassandra|$HOME/opt/cassandra/var/data|" $CONFIG_FILE
sed -i "s|/var/log/cassandra|$HOME/opt/cassandra/var/log|" cassandra/conf/log4j-server.properties

# Control Scripts
cat > cassandra/bin/start-cassandra.sh << EOF
#!/bin/sh

$HOME/opt/cassandra/bin/cassandra -p $HOME/opt/cassandra/var/cassandra.pid
EOF
chmod 755 cassandra/bin/start-cassandra.sh

cat > cassandra/bin/stop-cassandra.sh << EOF
#!/bin/sh

kill \`cat $HOME/opt/cassandra/var/cassandra.pid\`
EOF
chmod 755 cassandra/bin/stop-cassandra.sh

cat > $HOME/bin/cassandra-cli << EOF
#!/bin/sh

export CASSANDRA_HOME=$HOME/opt/cassandra
$HOME/opt/cassandra/bin/cassandra-cli \$*
EOF
chmod 755 $HOME/bin/cassandra-cli

# Setup nifty links
mkdir -p $HOME/bin
ln -s $HOME/opt/cassandra/bin/start-cassandra.sh $HOME/bin/
ln -s $HOME/opt/cassandra/bin/stop-cassandra.sh  $HOME/bin/

# Start Cassandra
cassandra/bin/start-cassandra.sh
