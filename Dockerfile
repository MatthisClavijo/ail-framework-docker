FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONIOENCODING=utf8

# Add missing packages
RUN apt update
RUN apt install -y git nodejs npm tor

# Copy project
COPY ail-framework/ /opt/ail-framework

# Compile and configure project
WORKDIR /opt/ail-framework
RUN sed -i "s|sudo||g" installing_deps.sh
RUN sed -i "s|sudo||g" var/www/update_thirdparty.sh
RUN ./installing_deps.sh
RUN sed -i "s|host = 127.0.0.1|host = 0.0.0.0|g" configs/core.cfg

# Add lacus
RUN git clone https://github.com/ail-project/lacus.git
WORKDIR /opt/ail-framework/lacus
RUN npm install -g playwright
RUN pip3 install poetry
RUN npm cache clean -f
RUN npm install -g n
RUN n stable
RUN pip3 uninstall -y virtualenv
RUN apt purge -y python3-virtualenv
RUN pip3 install virtualenv
RUN poetry install
RUN playwright install-deps
RUN echo LACUS_HOME="`pwd`" >> .env
RUN poetry run update --init --yes
WORKDIR /opt/ail-framework

# Update ail LAUNCH script 
RUN echo "service tor start" >> bin/LAUNCH.sh
RUN find / -type f -name "activate" -exec grep -q lacus {} \; -exec echo "source {}" >> bin/LAUNCH.sh \; 2>/dev/null 
RUN echo "cd lacus/ && poetry run start" >> bin/LAUNCH.sh
RUN echo "read x" >> bin/LAUNCH.sh

# Run project
EXPOSE 7000
ENTRYPOINT ["/bin/bash","bin/LAUNCH.sh"]
