FROM ubuntu:lunar 

RUN apt update

ENV install "apt install -y"
ENV installsudo "sudo apt install -y"

RUN $install git
RUN $install python3-pip
RUN $install gnuradio

RUN $install wget

# Para intentar que funcione el audio
RUN $install alsa-utils
RUN $install pulseaudio

# Para los builds
RUN $install cmake

# instalo QT5 para que al instalar fosphor, QT esté disponible
#RUN $install qt5-base


# Creo usuario y home directory
RUN useradd builder -m && passwd -d builder
ENV HOME "/home/builder"

# Los números son group id que se asignaron en mi sistema. Consultar con 'sudo getent group' en el host, para poder compartir recuersos.
RUN groupmod -g 44 video
#rUN groupmod -g 107 render
#RUN groupadd -g 46 plugdev
RUN groupmod -g 29 audio
# Main user -> builder para compartir archivos
#RUN usermod -u 1000 builder

# Asigno al usuario creado los grupos que corresponde, para que tengan acceso.
RUN usermod -aG video builder
#RUN usermod -aG render builder 
RUN usermod -aG plugdev builder 
RUN usermod -aG audio builder 

# Agrego reglas para permitir el uso del bus USB para el RTL-SDR sin ser root. Editar según el output de lsusb (de usbutils).
#RUN echo 'SUBSYSTEM=="usb", ATTRS{idVendor}=="0bda", ATTRS{idProduct}=="2838", GROUP="builder", MODE="0666", SYMLINK+="rtl_sdr"' > /etc/udev/rules.d/20.rtlsdr.rules 



RUN dpkg --add-architecture i386
RUN apt update
RUN $install sudo
RUN echo "builder ALL=(root) NOPASSWD:ALL" >> /etc/sudoers

RUN python3 -m pip install packages numpy matplotlib --break-system-packages
#qucs-s
RUN $install ngspice
RUN $install libqt5gui5
RUN $install libqt5core5a
RUN $install libqt5svg5 
RUN $install libqt5script5 
RUN $install libqt5widgets5 
RUN $install libqt5printsupport5 
USER builder
# Instalo dependencia
WORKDIR $HOME

RUN $installsudo python3-pip
RUN python3 -m pip install packages matplotlib numpy --break-system-packages

RUN $installsudo python3-gi gobject-introspection gir1.2-gtk-3.0
