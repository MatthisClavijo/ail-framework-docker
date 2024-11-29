FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONIOENCODING=utf8
ENV PATH="/root/.local/bin:$PATH"

# Add missing packages
RUN apt update
RUN apt install -y git nodejs npm pipx tor

# Copy ail-framework project
COPY ./ail-framework/ /opt/ail-framework

# Compile and configure ail-framework project
WORKDIR /opt/ail-framework
## Remove sudo
RUN sed -i "s|sudo||g" installing_deps.sh
RUN sed -i "s|sudo||g" var/www/update_thirdparty.sh
## Not interactive
RUN sed -i "s|apt-get|apt-get -y|g" installing_deps.sh
RUN sed -i "s|apt-get|apt-get -y|g" var/www/update_thirdparty.sh
## Compile and configure
RUN ./installing_deps.sh
RUN sed -i "s|host = 127.0.0.1|host = 0.0.0.0|g" configs/core.cfg

# Add lacus
RUN git clone https://github.com/ail-project/lacus.git
RUN git clone https://github.com/valkey-io/valkey.git
## Install dependencies
RUN apt install build-essential
## Compile valkey
WORKDIR /opt/ail-framework/valkey
RUN git checkout 8.0
RUN make
## Install lacus
WORKDIR /opt/ail-framework/lacus
## Install dependencies
RUN npm install -g playwright
RUN pipx install poetry
RUN npm cache clean -f
RUN npm install -g n
RUN n stable
RUN apt purge -y python3-virtualenv
RUN pipx install virtualenv
RUN poetry install
RUN playwright install-deps
RUN apt -y install ffmpeg libavcodec-extra
RUN echo LACUS_HOME="`pwd`" >> .env
RUN poetry run update --init --yes

# Update ail LAUNCH script
WORKDIR /opt/ail-framework
RUN echo "service tor start" >> bin/LAUNCH.sh
RUN find / -type f -name "activate" -exec grep -q lacus {} \; -exec echo "source {}" >> bin/LAUNCH.sh \; 2>/dev/null 
RUN echo "cd lacus/ && poetry run start" >> bin/LAUNCH.sh
RUN echo "read x" >> bin/LAUNCH.sh

# Run project
EXPOSE 7000
ENTRYPOINT ["/bin/bash","bin/LAUNCH.sh"]
