FROM archlinux:latest

RUN pacman -Syu --noconfirm

# Build toolchain
RUN pacman -S --noconfirm \
    base-devel \
    cmake \
    ninja \
    clang \
    lld \
    nodejs \
    git

# Qt6
RUN pacman -S --noconfirm \
    qt6-base \
    qt6-declarative \
    qt6-shadertools \
    qt6-5compat \
    qt6-canvaspainter

# Project-specific dependencies
RUN pacman -S --noconfirm \
    libqalculate \
    pipewire \
    aubio \
    cava \
    lm_sensors \
    glib2

# AUR: libcava (provides development headers for cava)
RUN pacman -S --needed --noconfirm sudo && \
    useradd -m builder && \
    echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    su builder -c " \
        git clone https://aur.archlinux.org/libcava.git /tmp/libcava && \
        cd /tmp/libcava && \
        makepkg -si --noconfirm \
    " && \
    rm -rf /tmp/libcava && \
    userdel -r builder && \
    sed -i '/^builder/d' /etc/sudoers
