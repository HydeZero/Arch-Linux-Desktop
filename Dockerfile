# This dockerfile sets up an Arch Linux environment, makes a new user, and installs a desktop (along with xrdp for remote desktop access).

# Use the official Arch Linux image as the base image
FROM archlinux:latest

# Setup the new default user
USER root
RUN pacman -Syu --noconfirm sudo git base-devel base
RUN useradd -m -G wheel -s /bin/bash user
RUN echo "default_pass" | passwd user --stdin
# Scary! We will un-nopasswd this after all steps, this is just to ensure proper install
RUN echo '%wheel ALL=(ALL) NOPASSWD:ALL' >> \
/etc/sudoers

# Switch to the user
USER user

# Install plasma (both wayland and x11)
RUN sudo pacman -Syu --noconfirm plasma plasma-x11-session

# Install yay (for xrdp)
WORKDIR /home/user
RUN git clone https://aur.archlinux.org/yay.git
WORKDIR /home/user/yay
RUN makepkg -si --noconfirm

# Install xrdp
RUN yay -S --noconfirm xrdp xorgxrdp

# Enable the xrdp service
RUN sudo systemctl enable xrdp.service

# Finally, return sudo BACK to regular.
USER root
WORKDIR /root
RUN /etc/sudoers > /root/sudoers.bak
RUN sed -i '/TEXT_TO_BE_REPLACED/c %wheel ALL=(ALL) NOPASSWD:ALL' /root/sudoers.bak
RUN mv /root/sudoers.bak /etc/sudoers
USER user
WORKDIR /home/user

RUN echo "ALL GOOD. Please RDP into the image."

CMD [ "echo", "default_pass", "|", "sudo", "-S", "systemctl", "start", "xrdp.service" ]