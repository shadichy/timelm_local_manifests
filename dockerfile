FROM cachyos/cachyos:latest

RUN yes | pacman -Syyu paru opendoas

COPY docker /

# RUN yes | pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
# RUN yes | pacman-key --lsign-key 3056513887B78AEB

# RUN yes | pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
# RUN yes | pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'

# RUN echo -e "[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist" > /etc/pacman.conf
# RUn sed -i 's/$arch/x86_64/g' /etc/pacman.d/chaotic-mirrorlist

RUN sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf

RUN useradd -m build

RUN rm -f /bin/sudo

RUN ln -s doas /bin/sudo

USER build

RUN yes | paru -S --skipreview --batchinstall --noconfirm lineageos-devel android-tools android-udev git git-lfs multilib-devel fontconfig ttf-droid python-pyelftools

WORKDIR /home/build

RUN git config --global user.email "shadichy@blisslabs.org"
RUN git config --global user.name "Shadichy"

RUN repo init -u https://github.com/BlissRoms/platform_manifest.git -b typhoon-qpr2 --git-lfs --depth=1 --manifest-depth=1 --no-tags

RUN mkdir -p .repo/local_manifests

COPY ./*.xml /home/build/.repo/local_manifests/

RUN repo sync -c --force-sync --no-tags --no-clone-bundle -j$(nproc) --optimized-fetch --prune

RUN bash /build.sh
