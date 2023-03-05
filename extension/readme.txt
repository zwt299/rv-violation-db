This is a Maven extension to run JavaMOP without changing the pom.xml file in a project.

Instructions:

mvn package
mvn_dir=$(mvn -version | grep ^Maven | cut -d: -f2 | tr -d ' ')
mkdir -p ${mvn_dir}/lib/ext # may need sudo access
bash 