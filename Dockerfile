FROM ubuntu:20.04

# Intall system utilities
RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update && \
    apt-get install -y --no-install-recommends tzdata &&\
    apt-get install -y \
    wget \
    curl \
    git \
    vim \
    gnupg \
    net-tools \
    iputils-ping \
    ipmitool \
    python3 \
    python3-dev \
    python3-pip \
    libreadline-dev \
    ca-certificates \
    build-essential \
    gdb && \
    curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends git-lfs && \
    git lfs install && \
    rm -rf /var/lib/apt/lists/*

# Install EPICS
ENV EPICS_BASE=/usr/local/src/epics/base-3.15.9

RUN mkdir -p "$EPICS_BASE"
WORKDIR $EPICS_BASE

RUN wget -c base-3.15.9.tar.gz https://github.com/epics-base/epics-base/archive/R3.15.9.tar.gz -O - | tar zx --strip 1 && \
    make clean && make -j"$(nproc)" && make install && \
    find . -maxdepth 1 \
    ! -name bin -a ! -name lib -a ! -name include -a ! -name startup \
    -exec rm -rf {} + || true

ENV EPICS_BASE=/usr/local/src/epics/base-3.15.9
ENV EPICS_HOST_ARCH=linux-x86_64
ENV PATH=/usr/local/src/epics/base-3.15.9/bin/linux-x86_64:${PATH}
ENV LD_LIBRARY_PATH="/usr/local/src/epics/base-3.15.9/lib/linux-x86_64:${LD_LIBRARY_PATH:-}"
ENV PYEPICS_LIBCA=/usr/local/src/epics/base-3.15.9/lib/linux-x86_64/libca.so

RUN pip3 install ipython numpy pyepics

# Add the IPMI package
WORKDIR /usr/local/src
ADD packages/IPMC.tar.gz .
ENV LD_LIBRARY_PATH=/usr/local/src/IPMC/lib64:${LD_LIBRARY_PATH}
ENV PATH=/usr/local/src/IPMC/bin/x86_64-linux-dbg:${PATH}

# Add the FirmwareLoader binary
RUN mkdir -p  /usr/local/src/FirmwareLoader/
ADD packages/FirmwareLoader.tar.gz /usr/local/src/FirmwareLoader/
ENV PATH=/usr/local/src/FirmwareLoader:${PATH}

# Add the ProgramFPGA utility
ADD packages/ProgramFPGA /usr/local/src/ProgramFPGA
ENV PATH=/usr/local/src/ProgramFPGA:${PATH}

# Create the user cryo and the group smurf. Add the cryo user
# to the smurf group, as primary group. And create its home
# directory with the right permissions.
RUN useradd -d /home/cryo -M cryo -u 1000 && \
    groupadd smurf -g 1001 && \
    usermod -aG smurf cryo && \
    usermod -g smurf cryo && \
    mkdir /home/cryo && \
    chown cryo:smurf /home/cryo

# Set the work directory to the root
WORKDIR /