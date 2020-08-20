# Objetivo

Necesitamos pasar por una VPN para acceder a algunos servicios, pero para el
resto de nuestras conexiones queremos evitar dicha VPN.

Una posible solución seria usar [IPTABLES con discriminación por usuario](https://www.niftiestsoftware.com/2011/08/28/making-all-network-traffic-for-a-linux-user-use-a-specific-network-interface/)
pero puede resultar demasiado complejo.

Por ello aquí se presenta una alternativa que consiste en crear una imagen
docker con un servidor SSH levantado y con la VPN configurada y activada
de manera que podamos hacer conexiones a través de la imagen solo cuando nos
interese ir a través de la VPN.

Nota: Este desarrollo esta montado sobre VPNC (Cisco VPN) porque es lo que
actualmente uso, pero sería fácilmente modificable para usar con OpenVPN
u otra alternativa.

# Piezas

* `config/default.conf` debe contener la configuración de nuestra VPNC
(ver plantilla en `config/default.example.conf`)
* `config/authorized_keys` debe incluir la clave pública con la que nos
queremos poder conectar a la máquina docker
* `init.sh` es el script que arrancara el servidor SSH y conectara la VPNC
al arrancar la imagen docker
* `Dockerfile` es la definición de nuestra imagen docker
* `img.sh` es un pequeño script para manejar la imagen

# Pasos

Para crear la clave ssh podemos hacer:

```
$ ssh-keygen -t rsa -f ~/.ssh/docker-vpnc -C "docker-vpnc"
$ cp ~/.ssh/docker-vpnc.pub config/authorized_keys
```

Para manejar la imagen tenemos:

* `./img.sh --build`: Crea la imagen
* `./img.sh --run`: Arranca la imagen
* `./img.sh --ssh`: Nos introduce en la imagen vía ssh
* `./img.sh --stop`: Para la imagen
* `./img.sh --rm`: Borra la imagen

# Configurar ~/.ssh/config

Una vez que tengamos nuestra imagen arrancada, podemos configurar muestro
`~/.ssh/config` de esta manera:

```
Host docker-vpnc
    HostName localhost
    User root
    Port 52022
    IdentityFile ~/.ssh/docker-vpnc

Host trb
    HostName 10.2.42.162
    IdentityFile ~/.ssh/trb
    User myuser
    Port 443
    ProxyJump docker-vpnc
```

y cuando queramos entrar a la máquina `10.2.42.162`, que es solo accesible a
través de la VPN, nos bastara con hacer `ssh trb` para entrar sin que ninguna
otra conexión de nuestro equipo se vea afectada por la VPN.