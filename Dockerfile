# Start with the NocoDB image which is based on Alpine
FROM nocodb/nocodb

# Set environment variables
ARG Ngrok
ARG Password
ARG re
ENV re=${re}
ENV Password=${Password}
ENV Ngrok=${Ngrok}
ENV LANG en_US.utf8

# Install necessary packages
RUN apk update \
    && apk add --no-cache openssh-server wget unzip \
    && rm -rf /var/cache/apk/*

# Configure SSH
RUN mkdir /var/run/sshd \
    && echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config \
    && echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config \
    && echo "root:${Password}" | chpasswd

# Download and configure ngrok
RUN wget -qO ngrok.zip https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.zip \
    && unzip ngrok.zip -d /usr/local/bin/ \
    && rm ngrok.zip \
    && echo "./ngrok config add-authtoken ${Ngrok}" >> /start.sh \
    && echo "./ngrok tcp 22 --region ${re} &>/dev/null &" >> /start.sh

# Add the command to start SSH to the script
RUN echo '/usr/sbin/sshd -D' >> /start.sh

# Make the start script executable
RUN chmod +x /start.sh

# Expose necessary ports
EXPOSE 80 8888 8080 443 5130 5131 5132 5133 5134 5135 3306 22

# Command to run the start script
CMD ["/start.sh"]
