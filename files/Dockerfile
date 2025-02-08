# DANGER: This Dockerfile contains intentional security risks!
# DO NOT USE THIS IN PRODUCTION. It is for educational purposes only.

FROM ubuntu:latest  # Using latest is generally discouraged in production

# Running as root (RISK: Container escape vulnerability)
USER root

# Installing unnecessary packages (RISK: Increased attack surface)
RUN apt-get update && \
    apt-get install -y vim curl wget net-tools iputils-ping traceroute nmap  # Lots of unnecessary tools

# Creating a user but not using it (RISK: Root still used for the main process)
RUN useradd -ms /bin/bash myuser

# Setting weak permissions on the MongoDB data directory (RISK: Data compromise)
RUN mkdir /data/db && \
    chmod 777 /data/db  # World-writable - HUGE RISK

# Exposing MongoDB to the world (RISK: Anyone can access the database)
EXPOSE 27017

# Installing MongoDB from an untrusted source (RISK: Potential backdoors) - Example, don't do this!
# In real life, use the official MongoDB image or a trusted repository.
RUN wget -qO - https://example.com/mongodb.deb | dpkg -i -  # Untrusted source - DO NOT DO THIS

# Adding a cron job that runs as root and could be easily modified (RISK: Privilege escalation)
RUN echo "* * * * * root echo 'This is a risky cron job!' >> /tmp/risky_cron.log" >> /etc/crontab

# Copying a sensitive file into the image (RISK: Data leak) - Example, don't do this!
COPY sensitive_data.txt /root/sensitive_data.txt  # Sensitive data in the image

# Running MongoDB in the foreground (RISK: Doesn't handle signals well)
CMD ["mongod", "--bind_ip_all"] # Binding to all IPs is very dangerous!
