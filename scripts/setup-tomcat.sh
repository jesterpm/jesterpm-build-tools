#!/bin/sh

TOMCAT_VERSION="7.0.42"

PASSWORD=$1

if [ -e $HOME/opt/tomcat ]; then
    echo "Tomcat appears to already be installed at $HOME/opt/tomcat. Skipping..."
    exit 1
fi

# Download
mkdir -p $HOME/opt
cd $HOME/opt
wget http://www.eng.lsu.edu/mirrors/apache/tomcat/tomcat-7/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz
tar xzf apache-tomcat-${TOMCAT_VERSION}.tar.gz
rm apache-tomcat-${TOMCAT_VERSION}.tar.gz
ln -s apache-tomcat-${TOMCAT_VERSION} tomcat

# Configure

if [ -z "$PASSWORD" ]; then
    echo -n "Enter a tomcat password (stored in plaintext): "
    read -s PASSWORD
fi

rm tomcat/conf/tomcat-users.xml
cat > tomcat/conf/tomcat-users.xml << EOF
<?xml version='1.0' encoding='utf-8'?>
<tomcat-users>
  <role rolename="manager-gui"/>
  <role rolename="manager-script"/>
  <!-- Remember: manager-gui and manager-script should not be assigned to
       the same user in production installations -->
  <user username="${USER}" password="${PASSWORD}" roles="manager-gui,manager-script"/>
</tomcat-users>
EOF
chmod 600 tomcat/conf/tomcat-users.xml

# Create the build.properties for other projects
cat > tomcat/conf/build.properties << EOF
catalina.home=${HOME}/opt/tomcat
manager.username=${USER}
manager.password=${PASSWORD}
EOF
chmod 600 tomcat/conf/build.properties

# Setup environment
if [ -z "$JAVA_HOME" ]; then
    JAVA_HOME=/usr/lib/jvm/java-7-oracle
fi

cat > tomcat/bin/setenv.sh << EOF
export CATALINA_HOME=$HOME/opt/tomcat
export JAVA_HOME=$JAVA_HOME
EOF

# Setup nifty links
mkdir -p $HOME/bin
ln -s $HOME/opt/tomcat/bin/startup.sh $HOME/bin/start-tomcat.sh
ln -s $HOME/opt/tomcat/bin/shutdown.sh $HOME/bin/stop-tomcat.sh

# Start tomcat
exec tomcat/bin/startup.sh
