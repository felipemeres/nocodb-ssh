# Start with the NocoDB image which is based on Alpine
FROM nocodb/nocodb

# Install necessary packages
RUN apk update > /dev/null 2>&1 && apk upgrade --available && apk add --no-cache openssh wget unzip

# Download and setup ngrok
RUN wget -O ngrok.zip https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.zip && \
    unzip ngrok.zip -d /usr/local/bin/ && \
    rm ngrok.zip

# Setup environment variables
ENV LANG en_US.utf8
ARG Ngrok
ARG Password
ARG re
ENV re=${re}
ENV Password=${Password}
ENV Ngrok=${Ngrok}

# Configure SSH
RUN ssh-keygen -A && \
    echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config && \
    echo "root:${Password}" | chpasswd

# Prepare the startup script
RUN echo "#!/bin/sh" > /start.sh && \
    echo "/usr/local/bin/ngrok config add-authtoken ${Ngrok}" >> /start.sh && \
    echo "/usr/local/bin/ngrok tcp 22 --region ${re} &>/dev/null &" >> /start.sh && \
    echo "/usr/sbin/sshd -D &" >> /start.sh && \
    echo "exec /usr/src/appEntry/start.sh" >> /start.sh && \
    chmod +x /start.sh

EXPOSE 80 8888 8080 443 5130 5131 5132 5133 5134 5135 3306

# Run the startup script
CMD ["/start.sh"]
