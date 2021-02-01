FROM archlinux:20200908

RUN pacman -Syy --noconfirm

ENV install "pacman -S --noconfirm --needed"

# Para permitir la ejecución sobre GTK3
RUN $install gtk3

RUN $install base-devel
RUN $install git
RUN $install xorgproto
RUN $install python-gobject
RUN $install archlinux-keyring
RUN $install gnuradio-companion
RUN $install swig
RUN $install python-pyzmq
RUN $install wget

# Para que funcione RTL-SDR. Es posible que solo uno de estos sea necesario.
RUN $install rtl-sdr
RUN $install gnuradio-osmosdr 

# Para intentar que funcione el audio
RUN $install alsa-utils
RUN $install pulseaudio

# Para poder consultar si detecta el device de OpenCL
RUN $install clinfo

# Para poder usar fosphor-glfw
RUN $install glfw-x11 

#RUN $install ocl-icd
RUN $install opencl-headers

# Los paquetes que necesitan los drivers de intel
RUN $install numactl
RUN $install gcc-libs 
RUN $install lib32-glibc
RUN $install lsb-release

# Para los builds
RUN $install cmake

# instalo QT5 para que al instalar fosphor, QT esté disponible
RUN $install qt5-base

# Biblioteca OpenCL libre que reemplaza a la de intel o a la de AMD. Tiene problemas con fosphor, porque instala OpenCL1.2, y fosphor lo blacklistea por buggy.
#RUN $install pocl

#RUN $install xterm

# I don't know how to suppress the annoying xterm_executable message.
# This was my best effort:
RUN sed -i 's/xterm_executable = /xterm_executable = true/' /etc/gnuradio/conf.d/grc.conf

# Creo usuario y home directory
RUN useradd builder -m && passwd -d builder
RUN echo "builder ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/builder
ENV HOME "/home/builder"

# Blacklisting para que el kernel de linux no levante el dongle de RTL-SDR como receptor de TV.
RUN echo 'blacklist dvb_usb_rtl28xxu' | sudo tee --append /etc/modprobe.d/blacklist-dvb_usb_rtl28xxu.conf

# Los números son group id que se asignaron en mi sistema. Consultar con 'sudo getent group' en el host, para poder compartir recuersos.
RUN groupmod -g 44 video
RUN groupmod -g 107 render
RUN groupadd -g 46 plugdev
RUN groupmod -g 29 audio
# Main user -> builder para compartir archivos
RUN usermod -u 1000 builder

# Asigno al usuario creado los grupos que corresponde, para que tengan acceso.
RUN sudo usermod -aG video builder
RUN sudo usermod -aG render builder 
RUN sudo usermod -aG plugdev builder 
RUN sudo usermod -aG audio builder 

# Agrego reglas para permitir el uso del bus USB para el RTL-SDR sin ser root. Editar según el output de lsusb (de usbutils).
RUN echo 'SUBSYSTEM=="usb", ATTRS{idVendor}=="0bda", ATTRS{idProduct}=="2838", GROUP="builder", MODE="0666", SYMLINK+="rtl_sdr"' > /etc/udev/rules.d/20.rtlsdr.rules 

# Instalo dependencia
USER builder
WORKDIR $HOME
RUN git clone https://aur.archlinux.org/debtap.git
WORKDIR $HOME/debtap
RUN makepkg -si --noconfirm

# OpenCL de AMD para CPUs (deprecado, AMD ya no los mantiene)
#WORKDIR $HOME
#RUN git clone https://aur.archlinux.org/amdapp-sdk.git
#WORKDIR $HOME/amdapp-sdk
#RUN makepkg -si --noconfirm

# Instalo ncurses5
WORKDIR $HOME
RUN mkdir -m=700 /home/builder/.gnupg
RUN echo "keyserver hkp://pool.sks-keyservers.net" > /home/builder/.gnupg/gpg.conf
RUN gpg --recv-key 702353E0F7E48EDB # Must be run by builder user
RUN git clone https://aur.archlinux.org/ncurses5-compat-libs.git
WORKDIR $HOME/ncurses5-compat-libs
RUN makepkg -si --noconfirm

# Instalo OpenCL driver de Intel desde AUR.
WORKDIR $HOME
RUN git clone https://aur.archlinux.org/intel-opencl.git
WORKDIR $HOME/intel-opencl
RUN makepkg -si --noconfirm

# Instalo fosphor desde AUR
WORKDIR $HOME
RUN git clone https://aur.archlinux.org/gr-fosphor.git
WORKDIR $HOME/gr-fosphor
RUN makepkg -si --noconfirm

# Instalo fosphor desde repositorio oficial
#WORKDIR $HOME
#RUN git clone git://git.osmocom.org/gr-fosphor
#WORKDIR $HOME/gr-fosphor
#RUN mkdir build
#WORKDIR $HOME/gr-fosphor/build
#RUN cmake ..
#RUN make
#RUN sudo make install
#RUN sudo ldconfig


WORKDIR $HOME
COPY --chown=builder docksphor.grc .



# Instalo phychic desde el github de fran
WORKDIR $HOME
RUN git clone https://github.com/franalbani/gr-phychic.git
WORKDIR $HOME/gr-phychic
RUN bash tools/arch_build_helper 

# Instalo RTL-SDR desde repositorio oficial
#WORKDIR $HOME
#RUN git clone git://git.osmocom.org/rtl-sdr
#WORKDIR $HOME/rtl-sdr
#RUN autoreconf -i
#RUN ./configure 
#RUN make
#RUN sudo make install
#RUN sudo make install-udev-rules
#RUN sudo ldconfig

# Instalo OSMOSDR desde repositorio oficial
#WORKDIR $HOME
#RUN git clone git://git.osmocom.org/gr-osmosdr
#WORKDIR $HOME/gr-osmosdr
#RUN mkdir build
#WORKDIR $HOME/gr-osmosdr/build
#RUN cmake ../
#RUN make
#RUN sudo make install

USER builder
RUN sudo ldconfig
CMD ["/usr/bin/gnuradio-companion", "docksphor.grc"]
