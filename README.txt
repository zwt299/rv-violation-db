cd ${HOME}/javamop-agent-bundle/

# Make the agent
bash make-agent.sh props agents quiet

# install the agent
mvn install:install-file -Dfile=agents/JavaMOPAgent.jar -DgroupId="javamop-agent" -DartifactId="javamop-agent" -Dversion="1.0" -Dpackaging="jar"

# To add JavaMOP to a Maven-based Java project, modify the `pom.xml` in that project to look like so:

```xml
<build>
  ...
  <plugins>
    ...
    <plugin>
      <groupId>org.apache.maven.plugins</groupId>
      <artifactId>maven-surefire-plugin</artifactId>
      <version>2.16</version>
      <configuration>
        <argLine>-javaagent:${settings.localRepository}/javamop-agent/javamop-agent/1.0/javamop-agent-1.0.jar</argLine>
      </configuration>
    </plugin>
    ...
  </plugins>
</build>
```
