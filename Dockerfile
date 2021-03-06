###########################################################################
# Dockerfile that contains SteamCMD and a script to update Starbound Server
###########################################################################
FROM debian:buster-slim

ENV STEAMCMDDIR /home/steam/steamcmd
ENV STEAM_USERNAME "moo_uk"
ENV STEAM_PASSWORD ""
ENV STEAMAPPID 533830
ENV STEAMAPPDIR /home/steam/starbound-dedicated

# Install, update & upgrade packages
# Create user for the server
# This also creates the home directory we later need
# Clean TMP, apt-get cache and other stuff to make the image smaller
# Create Directory for SteamCMD
# Download SteamCMD
# Extract and delete archive
RUN set -x \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends --no-install-suggests \
		lib32stdc++6=8.3.0-6 \
		lib32gcc1=1:8.3.0-6 \
		wget=1.20.1-1.1 \
		ca-certificates=20190110 \
	&& useradd -m steam \
	&& su steam -c \
		"mkdir -p ${STEAMCMDDIR} \
		&& cd ${STEAMCMDDIR} \
		&& wget -qO- 'https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz' | tar zxf -" \
	&& apt-get remove --purge -y \
		wget \
	&& apt-get clean autoclean \
	&& apt-get autoremove -y \
	&& rm -rf /var/lib/apt/lists/*

# Create a script to easily update the server
RUN echo "${STEAMCMDDIR}/steamcmd.sh +login ${STEAM_USERNAME} ${STEAM_PASSWORD} +force_install_dir ${STEAMAPPDIR} +app_update ${STEAMAPPID} +quit" >> ${STEAMCMDDIR}/updateStarboundServer.sh \
    && chmod 777 ${STEAMCMDDIR}/updateStarboundServer.sh 

# Switch to user steam
USER steam

WORKDIR $STEAMCMDDIR