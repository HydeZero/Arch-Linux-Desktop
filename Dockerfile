# This dockerfile sets up an Arch Linux environment, makes a new user, and installs a desktop (along with xrdp for remote desktop access).

# Use the official Arch Linux image as the base image
FROM archlinux:latest

# Setup the new default user
USER root
RUN pacman -Syu --noconfirm sudo git
RUN useradd -m -G wheel -s /bin/bash user
RUN echo "default_pass" | passwd user --stdin
RUN echo '%wheel ALL=(ALL) ALL:ALL' >> \
/etc/sudoers

# Switch to the user
USER user

# Install plasma (both wayland and x11)
RUN echo "default_pass" | sudo -S pacman -Syu --noconfirm plasma plasma-x11-session

# Install yay (for xrdp)
RUN cd /home/user && git clone https://aur.archlinux.org/yay.git && \
    cd yay && \
    makepkg -si --noconfirm

# Install xrdp
RUN yay -S --noconfirm xrdp xorgxrdp

# Enable the xrdp service
RUN echo "default_pass" | sudo -S systemctl enable xrdp.service

# Start the xrdp service
RUN echo "default_pass" | sudo -S systemctl start xrdp.service

RUN echo "ALL GOOD. Please RDP into the image."