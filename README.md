# Forcepoint VPN Client Linux over SOCKS5
<p>Dockerfile para criar uma imagem Docker para disponibilizar um serviço SOCKS5 para acesso ao cliente VPN ForcePoint.</p>
<h4>Variáveis:</h4>
LOGIN</br>
PASSW</br>
SERVER</br>
CLIENT_FILE_SITE</br>
DEBFILE</br>

<h4>Criar imagem:</h4>
<p>docker build -t forcepoint-client:2.5.0 .</p>

<h4>Criar container:</h4>
docker run -dit --restart always --privileged --cap-add=NET_ADMIN -e SERVER=vpnssl.company.com -e LOGIN=user@company.com -e PASSW=pass --device=/dev/net/tun -p 1337:1337 --name forcepoint-client_2.5.0 forcepoint-client:2.5.0</br></br>
<h4>Exemplo de uso:</h4>

<h5>1° Criar um perfil configurado para apontar para o SOCKS5.</h5>

![image](https://user-images.githubusercontent.com/39818426/228361078-e122381c-3f2e-46cc-a32d-df1d09b51320.png)

<h5>2° Configurar o perfil auto switch com os endereços que passarão pela VPN over SOCKS5.</h5>

![image](https://user-images.githubusercontent.com/39818426/228361334-d5cca19c-f1d0-49de-b8a7-e09f6ba8e033.png)

<h5>Por último, definir o perfil auto switch como o padrão.</h5>

![image](https://user-images.githubusercontent.com/39818426/228360805-cf071524-25df-4034-9f48-16bd432b3330.png)

<h4>Proxy SwitchyOmega na loja da Google:</h4>
<p>https://chrome.google.com/webstore/detail/proxy-switchyomega/padekgcemlokbadohgkifijomclgjgif</p>


<p></p>

