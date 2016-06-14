#!/bin/sh

dots()
{
  while true; do printf "."; sleep 0.4; done &
  sleep 2 ;
  kill $! ; printf "\n"
}

printf "[INFO] Building project, it might take a while " ; dots
# run maven on main repo
cd /home/pt && mvn clean package install -DskipTests
# run maven on hadoop dist
cd /home/pt/hadoop && mvn clean package install -Pdist -DskipTests -Dmaven.javadoc.skip="true"
# remove if it exists -> prevents error msg on first build
if [ -d "/home/pt/hadoop-config " ]; then
  rm -r /home/pt/hadoop-config
fi
# copy and edit config script
cp -r /home/pt/hadoop/hadoop-dist/target/hadoop-2.7.2/etc/hadoop/ /home/pt/hadoop-config/
perl -0777 -pi -e 's/<configuration>\n<\/configuration>/<configuration>\n\t<property>\n\t\t<name>fs\.default\.name<\/name>\n\t\t<value>hdfs\:\/\/127\.0\.0\.1\:9000<\/value>\n\t<\/property>\n<\/configuration>/g' /home/pt/hadoop-config/core-site.xml

printf "[INFO] 'pivot-tracing' built!"
