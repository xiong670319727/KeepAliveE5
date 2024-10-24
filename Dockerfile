FROM ubuntu:22.04

# Copy Files
COPY . /KeepAliveE5

WORKDIR /KeepAliveE5
# Link Wrapper File
RUN chmod +x *.sh local/* && \
    ln -s /KeepAliveE5/local/run /usr/bin/run

# Install Bootstrap Utils
RUN apt-get update && \
    apt-get install -y curl gnupg

# Change Sources
RUN curl -sm3 -o/dev/null google.com || run change_source

# Install Git
RUN apt-get update && \
    apt-get install -y git

# Install Chromium Dependencies
# https://gist.github.com/winuxue/cfef08e2f5fe9dfc16a1d67a4ad38a01
RUN apt-get install -y gconf-service libasound2 libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 ca-certificates fonts-liberation libappindicator1 libnss3 lsb-release xdg-utils wget libatk-bridge2.0-0 libgbm-dev

# Install Node.js LTS
RUN apt-get update && \
    curl -sL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs

# Install Python 3 LTS
# https://www.cnblogs.com/jsxubar/p/17622352.html
RUN grep -q deadsnakes /etc/apt/sources.list || \
    apt-get install software-properties-common -y 
RUN grep -q deadsnakes /etc/apt/sources.list || \
    add-apt-repository ppa:deadsnakes/ppa -y
# RUN grep -q deadsnakes /etc/apt/sources.list && \
#     sed -i 's/^\([^#]\)/#\1/g' /etc/apt/sources.list.d/deadsnakes*

RUN apt-get update && \
    apt-get install -y python3.10

# Install Pip 3
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.10
ENV PATH="${PATH}:/root/.local/bin"

# Install Poetry 1.3.2
RUN pip3.10 install poetry==1.3.2 --root-user-action=ignore

# Install Azure CLI 2.39.0
RUN pip3.10 install azure-cli==2.39.0 --root-user-action=ignore

# Install Nodejs Dependencies
WORKDIR /KeepAliveE5/register
RUN npm install --verbose

# Install Python Dependencies
WORKDIR /KeepAliveE5
RUN poetry config virtualenvs.create true --local && \
    poetry config virtualenvs.in-project true --local && \
    poetry config installer.parallel --local && \
    poetry install --no-interaction --no-root --only main

# Set Timezone
# https://stackoverflow.com/questions/44331836/apt-get-install-tzdata-noninteractive
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends tzdata
ENV TZ=Asia/Shanghai

# Install Cron
RUN apt-get -y install cron

# Clean
RUN apt autoclean -y && \
    apt autoremove --purge -y && \
    apt clean -y && \
    rm -rf /var/lib/apt/lists/*

# Keep the Container Running
CMD ["cron", "-f"]
