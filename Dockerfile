FROM ubuntu:22.04
LABEL version="1.0.42" 
LABEL maintainer="Wander Sfalsin<wandersfalsin@gmail.com>"
LABEL description="Disponibilizando serviço SOCKS5 para acesso ao cliente VPN ForcePoint. docker run sugerido: docker run -dit --restart always --privileged --cap-add=NET_ADMIN -e SERVER=vpnssl.company.com -e LOGIN=user@company.com -e PASSW=pass --device=/dev/net/tun -p 1337:1337 --name force forcepoint-client:2.5.0"

#Variáveis
ENV LOGIN=${LOGIN}
ENV PASSW=${PASSW}
ENV SERVER=${SERVER}
ENV CLIENT_FILE_SITE="https://download.escope.net/Forcepoint/vpn%20client/6.10.0/ForcepointVPNClientLinux.zip"
ENV DEBFILE="forcepoint-client_2.5.0+buster_amd64.deb"

#Atualiza SO e instala pacotes
RUN apt-get update
RUN apt-get dist-upgrade -y
RUN apt-get install curl unzip openssh-client openssh-server tzdata -yq
RUN ln -fs /usr/share/zoneinfo/America/Araguaina /etc/localtime && dpkg-reconfigure -f noninteractive tzdata

#Baixa cliente ForcePoint-Linux e descompacta
RUN curl -SL ${CLIENT_FILE_SITE} -o ForcepointVPNClientLinux.zip
RUN unzip ForcepointVPNClientLinux.zip -d ./ForcepointVPNClientLinux

#Baixa todas as dependencias, instala tudo e limpa os arquivos de instalação
RUN curl -SL http://mirrors.kernel.org/ubuntu/pool/main/libe/libevent/libevent-2.1-6_2.1.8-stable-4build1_amd64.deb -o ./ForcepointVPNClientLinux/libevent-2.1-6_2.1.8-stable-4build1_amd64.deb
RUN curl -SL http://mirrors.kernel.org/ubuntu/pool/main/libe/libevent/libevent-openssl-2.1-6_2.1.8-stable-4build1_amd64.deb -o ./ForcepointVPNClientLinux/libevent-openssl-2.1-6_2.1.8-stable-4build1_amd64.deb
RUN curl -SL http://security.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1-1ubuntu2.1~18.04.21_amd64.deb -o ./ForcepointVPNClientLinux/libssl1.1_1.1.1-1ubuntu2.1~18.04.21_amd64.deb
RUN curl -SL http://mirrors.kernel.org/ubuntu/pool/main/libe/libevent/libevent-pthreads-2.1-6_2.1.8-stable-4build1_amd64.deb -o ./ForcepointVPNClientLinux/libevent-pthreads-2.1-6_2.1.8-stable-4build1_amd64.deb
RUN curl -SL http://mirrors.kernel.org/ubuntu/pool/main/libe/libevent/libevent-core-2.1-6_2.1.8-stable-4build1_amd64.deb -o ./ForcepointVPNClientLinux/libevent-core-2.1-6_2.1.8-stable-4build1_amd64.deb
RUN curl -SL http://mirrors.kernel.org/ubuntu/pool/main/e/expat/libexpat1_2.2.5-3ubuntu0.9_amd64.deb -o ./ForcepointVPNClientLinux/libexpat1_2.2.5-3ubuntu0.9_amd64.deb
RUN curl -SL http://mirrors.kernel.org/ubuntu/pool/main/libn/libnl3/libnl-3-200_3.2.29-0ubuntu3_amd64.deb -o ./ForcepointVPNClientLinux/libnl-3-200_3.2.29-0ubuntu3_amd64.deb
RUN curl -SL http://mirrors.kernel.org/ubuntu/pool/main/libn/libnl3/libnl-route-3-200_3.2.29-0ubuntu3_amd64.deb -o ./ForcepointVPNClientLinux/libnl-route-3-200_3.2.29-0ubuntu3_amd64.deb
RUN dpkg -i ./ForcepointVPNClientLinux/l*.deb
RUN dpkg -i ./ForcepointVPNClientLinux/${DEBFILE}
RUN rm -fr ./ForcepointVPNClientLinux*

#Atualiza alguns pacotes instataldos pelo comando anterior e limpa cache
RUN apt-get dist-upgrade -y
RUN apt-get autoremove -y && apt-get autoclean -y && apt-get clean -y

#Prepara serviço SSH
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN ssh-keygen -b 2048 -t rsa -f ~/.ssh/id_rsa -q -N "" && cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
RUN mkdir /var/run/sshd

#Fazer cache de 'resolvconf'
RUN apt-get install --download-only resolvconf

EXPOSE 1337

HEALTHCHECK --interval=60s --timeout=3s \
CMD curl -f $(echo $LOGIN | awk -F"@" '{print $2}') 2>/dev/null 1>&2 || exit 1

CMD	umount -l /etc/resolv.conf && \
	apt-get install resolvconf -y && \
	echo 'nameserver 8.8.8.8' >  /etc/resolvconf/resolv.conf.d/base && \	
	resolvconf -u && \
	/etc/init.d/ssh start && \
	/usr/sbin/forcepoint-client ${SERVER} --certaccept -u ${LOGIN} -a ${PASSW} -V --retry --resolver /usr/sbin/resolvconf --daemonize && \
	ssh -o StrictHostKeyChecking=accept-new -4 -N -D 0.0.0.0:1337 localhost 
