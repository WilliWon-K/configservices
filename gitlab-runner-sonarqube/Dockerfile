FROM gitlab/gitlab-runner:latest

# Installer les dépendances nécessaires
RUN apt-get update && apt-get install -y \
    curl unzip openjdk-17-jre ca-certificates nodejs \
    python3 python3-pip python3-venv \
    && rm -rf /var/lib/apt/lists/*

# Copier les certificats
COPY ./config/config.toml /etc/gitlab-runner/config.toml
COPY ./certs/gitlab-fullchain.crt /usr/local/share/ca-certificates/gitlab-fullchain.crt
COPY ./certs/sonarqube-fullchain.crt /usr/local/share/ca-certificates/sonarqube-fullchain.crt
COPY ./certs/DataInter.crt /usr/local/share/ca-certificates/
COPY ./certs/DataIntermediaire.crt /usr/local/share/ca-certificates/
COPY ./certs/DataRoot.crt /usr/local/share/ca-certificates/
COPY jdk.net.hosts.file /etc/gitlab-runner/jdk.net.hosts.file

# Mettre à jour les certificats
RUN update-ca-certificates

# Télécharger et installer SonarScanner
RUN curl -o /tmp/sonar-scanner.zip -L "https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.3006-linux.zip" \
    && unzip /tmp/sonar-scanner.zip -d /opt \
    && rm /tmp/sonar-scanner.zip

# Ajouter SonarScanner au PATH
ENV PATH="$PATH:/opt/sonar-scanner-5.0.1.3006-linux/bin"

# Ajouter les certificats dans le keystore SonarScanner
RUN keytool -import -trustcacerts -keystore /opt/sonar-scanner-5.0.1.3006-linux/jre/lib/security/cacerts -storepass changeit -noprompt -alias sonarqube-fullchain -file /usr/local/share/ca-certificates/sonarqube-fullchain.crt && \
    keytool -import -trustcacerts -keystore /opt/sonar-scanner-5.0.1.3006-linux/jre/lib/security/cacerts -storepass changeit -noprompt -alias sofa-intermediaire -file /usr/local/share/ca-certificates/DataIntermediaire.crt && \
    keytool -import -trustcacerts -keystore /opt/sonar-scanner-5.0.1.3006-linux/jre/lib/security/cacerts -storepass changeit -noprompt -alias sofa-inter -file /usr/local/share/ca-certificates/DataInter.crt && \
    keytool -import -trustcacerts -keystore /opt/sonar-scanner-5.0.1.3006-linux/jre/lib/security/cacerts -storepass changeit -noprompt -alias sofa-root -file /usr/local/share/ca-certificates/DataRoot.crt && \
    keytool -import -trustcacerts -keystore /opt/sonar-scanner-5.0.1.3006-linux/jre/lib/security/cacerts -storepass changeit -noprompt -alias gitlab-fullchain -file /usr/local/share/ca-certificates/gitlab-fullchain.crt

# Mise à jour finale des certificats
RUN update-ca-certificates

# Ajouter le script d'entrée
COPY entrypoint.sh /entrypoint
RUN chmod +x /entrypoint

# Définir le point d'entrée
ENTRYPOINT ["/entrypoint"]
