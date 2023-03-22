#!bin/bash 
cd ~/javamop/
mvn clean
bash scripts/install-javaparser.sh
mvn package -Drat.skip -DskipTests

cd ~/rv-violation-db/extension/
mvn package
mvn_dir=$(mvn -version | grep ^Maven | cut -d: -f2 | tr -d ' ')
mkdir -p ${mvn_dir}/lib/ext
cp target/mop-extension-1.0-SNAPSHOT.jar ${mvn_dir}/lib/ext

cd ~/javamop-agent-bundle/

###HANDLE SPECIFIC AGENTS###
bash make-agent.sh props/ agents/ quiet


###INSTALL JAVAMOPAGENT.JAR
mvn install:install-file -Dfile=agents/JavaMOPAgent.jar -DgroupId="javamop-agent" -DartifactId="javamop-agent" -Dversion="1.0" -Dpackaging="jar"
export RVMLOGGINGLEVEL=UNIQUE


