# This dockerfile sets up an Arch Linux environment, makes a new user, and installs a desktop (along with xrdp for remote desktop access).

# Use the official Arch Linux image as the base image
FROM archlinux:latest

# Setup the new default user
USER root
RUN useradd -m -G wheel -s /bin/bash user

# Switch to the user
USER user

# Install plasma (both wayland and x11)
RUN sudo pacman -Syu --noconfirm plasma plasma-x11-session

# Install yay (for xrdp)
RUN git clone https://aur.archlinux.org/yay.git && \
    cd yay && \
    makepkg -si --noconfirm

# Install xrdp
RUN yay -S --noconfirm xrdp xorgxrdp

# Enable the xrdp service
RUN sudo systemctl enable xrdp.service

# Start the xrdp service
RUN sudo systemctl start xrdp.service