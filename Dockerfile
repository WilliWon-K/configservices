FROM gitlab/gitlab-runner:latest

# Installer les dépendances nécessaires, y compris OpenJDK 17
RUN apt-get update && apt-get install -y \
    curl unzip openjdk-17-jre ca-certificates nodejs && \
    rm -rf /var/lib/apt/lists/*

# Copier les certificats
COPY ./config/config.toml /etc/gitlab-runner/config.toml
COPY gitlab-fullchain.crt /usr/local/share/ca-certificates/gitlab-fullchain.crt
COPY sonarqube-fullchain.crt /usr/local/share/ca-certificates/sonarqube-fullchain.crt
COPY jdk.net.hosts.file /etc/gitlab-runner/jdk.net.hosts.file
COPY DataIntermediaire.crt /usr/local/share/ca-certificates/
COPY DataRoot.crt usr/local/share/ca-certificates/

# Mettre à jour les certificats
RUN update-ca-certificates

# Télécharger et installer SonarScanner
RUN curl -o /tmp/sonar-scanner.zip -L "https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.3006-linux.zip" \
    && unzip /tmp/sonar-scanner.zip -d /opt \
    && rm /tmp/sonar-scanner.zip

# Ajouter SonarScanner au PATH
ENV PATH="$PATH:/opt/sonar-scanner-5.0.1.3006-linux/bin"

# Ajouter le certificat SonarQube au keystore Java d'OpenJDK 17
RUN keytool -import -trustcacerts \
    -keystore /opt/sonar-scanner-5.0.1.3006-linux/jre/lib/security/cacerts \
    -storepass changeit -noprompt \
    -alias sonarqube-fullchain -file /usr/local/share/ca-certificates/sonarqube-fullchain.crt

RUN keytool -import -trustcacerts \
    -keystore /opt/sonar-scanner-5.0.1.3006-linux/jre/lib/security/cacerts \
    -storepass changeit -noprompt \
    -alias sofa-intermediaire -file /usr/local/share/ca-certificates/DataIntermediaire.crt

RUN keytool -import -trustcacerts \
    -keystore /opt/sonar-scanner-5.0.1.3006-linux/jre/lib/security/cacerts \
    -storepass changeit -noprompt \
    -alias sofa-root -file /usr/local/share/ca-certificates/DataRoot.crt
        
RUN keytool -import -trustcacerts \
    -keystore /opt/sonar-scanner-5.0.1.3006-linux/jre/lib/security/cacerts \
    -storepass changeit -noprompt \
    -alias gitlab-fullchain -file /usr/local/share/ca-certificates/gitlab-fullchain.crt

# Mettre à jour encore une fois après l'ajout du certificat
RUN update-ca-certificates
RUN git config --global http.sslCAInfo /usr/local/share/ca-certificates/gitlab-fullchain.crt
RUN git config --global http.sslbackend gnutls

# Ajouter JAVA_HOME pour qu'il pointe vers OpenJDK 17
#ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
#ENV PATH="${JAVA_HOME}/bin:${PATH}"
#ENV JAVA_TOOL_OPTIONS=-Djdk.net.hosts.file=/etc/gitlab-runner/jdk.net.hosts.file

# Forcer le JVM à utiliser le bon cacerts (et ne pas utiliser Amazon Corretto)
#ENV JAVA_OPTS="-Djavax.net.ssl.trustStore=${JAVA_HOME}/lib/security/cacerts -Djavax.net.ssl.trustStorePassword=changeit"
#ENV SONAR_SCANNER_JAVA_OPTS="-Djavax.net.ssl.trustStore=${JAVA_HOME}/lib/security/cacerts -Djavax.net.ssl.trustStorePassword=changeit"

RUN echo "if [ -f ~/.bashrc ]; then \n . ~/.bashrc \n fi" >> ~/.bash_profile

# Vérifier l'installation de SonarScanner et Docker
RUN sonar-scanner --version

# Copier le script d'entrée
COPY entrypoint.sh /entrypoint
RUN chmod +x /entrypoint

# Définir le point d’entrée
ENTRYPOINT ["/entrypoint"]
