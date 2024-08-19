FROM ubuntu:lunar 

RUN apt update

ENV install "apt install -y"
ENV installsudo "sudo apt install -y"

RUN $install git
RUN $install python3-pip
RUN $install gnuradio

RUN $install wget

# Audio stuff
RUN $install alsa-utils
RUN $install pulseaudio

# Build stuff ;-)
RUN $install cmake

# Create user and home directory
#RUN useradd -m -r -u 1000 ubuntu && passwd -d ubuntu
ENV HOME="/home/ubuntu"

# Enable sharing of some host resources by adding the user to some predefined groups.
RUN groupmod -g 44 video
RUN groupmod -g 29 audio

# Assign user to corresponding groups
RUN usermod -aG video ubuntu
RUN usermod -aG plugdev ubuntu 
RUN usermod -aG audio ubuntu

# Add rules to allow for the use of USB bus for RTL-SDR. Edit according to the output of lsusb command
#RUN echo 'SUBSYSTEM=="usb", ATTRS{idVendor}=="0bda", ATTRS{idProduct}=="2838", GROUP="builder", MODE="0666", SYMLINK+="rtl_sdr"' > /etc/udev/rules.d/20.rtlsdr.rules 



RUN dpkg --add-architecture i386
RUN apt update
RUN $install sudo
RUN echo "ubuntu ALL=(root) NOPASSWD:ALL" >> /etc/sudoers

RUN python3 -m pip install packages numpy matplotlib --break-system-packages

RUN $install ngspice
RUN $install libqt5gui5
RUN $install libqt5core5a
RUN $install libqt5svg5 
RUN $install libqt5script5 
RUN $install libqt5widgets5 
RUN $install libqt5printsupport5 
USER ubuntu

# Install dependencies 
WORKDIR $HOME

RUN $installsudo python3-pip
RUN python3 -m pip install packages matplotlib numpy --break-system-packages

RUN $installsudo python3-gi gobject-introspection gir1.2-gtk-3.0

# install gr-satellites
RUN $installsudo software-properties-common
RUN sudo add-apt-repository -y ppa:daniestevez/gr-satellites
RUN sudo apt update

# install fosphor and opencl drivers
RUN $installsudo ocl-icd-libopencl1
RUN $installsudo ocl-icd-opencl-dev
RUN $installsudo opencl-headers
RUN $installsudo pocl-opencl-icd
RUN $installsudo gr-fosphor
RUN $installsudo gr-limesdr
RUN $installsudo gr-osmosdr

RUN $installsudo libspdlog-dev
RUN $installsudo libsndfile1-dev
RUN $installsudo liborc-0.4-dev
RUN $installsudo python3-construct
RUN $installsudo python3-requests
RUN python3 -m pip install websocket-client --break-system-packages

RUN git clone https://github.com/daniestevez/gr-satellites.git
WORKDIR /home/ubuntu/gr-satellites
RUN git checkout v5.5.0
RUN mkdir build
WORKDIR /home/ubuntu/gr-satellites/build
RUN cmake ..
RUN make
RUN sudo make install
RUN sudo ldconfig

WORKDIR /home/ubuntu

## Section to consider Intel CPUs
RUN $installsudo clinfo intel-opencl-icd
