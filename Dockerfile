# Use nocodb/nocodb as the base image
FROM nocodb/nocodb

# Set environment variables
ENV LANG en_US.utf8
ARG Ngrok
ARG Password
ARG re
ENV re=${re}
ENV Password=${Password}
ENV Ngrok=${Ngrok}

# Install necessary packages (may need adaptation if the base image is not Debian/Ubuntu-based)
RUN apt-get update -y > /dev/null 2>&1 && \
    apt-get upgrade -y > /dev/null 2>&1 && \
    apt-get install locales ssh wget unzip -y > /dev/null 2>&1 && \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

# Download and unzip ngrok
RUN wget -O ngrok.zip https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.zip > /dev/null 2>&1 && \
    unzip ngrok.zip

# Configure ngrok and ssh
RUN echo "./ngrok config add-authtoken ${Ngrok} &&" >>/1.sh && \
    echo "./ngrok tcp 22 --region ${re} &>/dev/null &" >>/1.sh && \
    mkdir /run/sshd && \
    echo '/usr/sbin/sshd -D' >>/1.sh && \
    echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config && \
    echo root:${Password}|chpasswd && \
    service ssh start && \
    chmod 755 /1.sh

# Expose necessary ports
EXPOSE 80 8888 8080 443 5130 5131 5132 5133 5134 5135 3306

# Run the script on container startup
CMD ["/1.sh"]
