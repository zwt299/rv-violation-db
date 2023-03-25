#!bin/bash 
cd ../javamop/
mvn clean
bash scripts/install-javaparser.sh
mvn package -Drat.skip -DskipTests

cd ../rv-violation-db/extension/
mvn package
mvn_dir=$(mvn -version | grep ^Maven | cut -d: -f2 | tr -d ' ')
mkdir -p ${mvn_dir}/lib/ext
cp target/mop-extension-1.0-SNAPSHOT.jar ${mvn_dir}/lib/ext

cd ../javamop-agent-bundle/
bash make-agent.sh props/ agents/ quiet
mvn install:install-file -Dfile=agents/JavaMOPAgent.jar -DgroupId="javamop-agent" -DartifactId="javamop-agent" -Dversion="1.0" -Dpackaging="jar"
export RVMLOGGINGLEVEL=UNIQUE



# Then Clone the Project that you are trying to work on


#Clone the repo in the setup list 
git clone https://github.com/eclipse/jetty.project.git
cd jetty.project/jetty-util
git checkout df1f709ea2f883ffb7f0a87d63aac506ae3fedd5
mvn test -Dtest=QueuedThreadPoolTest#testMaxStopTime -Denforcer.skip