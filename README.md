# Сервис для проксирования traefik

## Инициализация

- создаем (проверяем наличие) в днс-зоне своей записи вида `traefik.domain.ru`
- заполняем переменную `TRAEFIK_HOST=traefik.domain.ru`
- в файлике data/traefik.yml поправьте внизу значение `devops@domain.ru` на свое валидное
- запускаем `init.sh` (он создает файлик data/acme.json и придает ему правильные права)

## Внешняя защита

Так как сам сервис trafik доступен из вне, его так же логично закрыть хотя бы basic auth
В папку `data` сгенерим файлик `basic.auth` c логином и паролем

```
htpasswd -c data/basic.auth admin
```

## Запуск

- `docker-compose up -d`

## Докерные сервисы

- запускаем нужный контейнер с правильно выставленными `лейблами`
- контейнер должен быть в том числе подключен к сети `webproxy`

**Пример**:

```
version: '3.7'
services:
    grafana:
      container_name: grafana
      image: grafana/grafana:latest
      restart: always
      labels:
        - "traefik.enable=true"
        - "traefik.http.routers.grafana.entrypoints=https"
        - "traefik.http.routers.grafana.rule=Host(`grafana.domain.ru`)"
        - "traefik.http.routers.grafana.tls=true"
        - "traefik.http.routers.grafana.tls.certresolver=letsEncrypt"
        - "traefik.http.services.grafana-service.loadbalancer.server.port=3000"
        - "traefik.docker.network=webproxy"
      environment:
        - GF_SECURITY_ADMIN_PASSWORD=${GF_SECURITY_ADMIN_PASSWORD}
        - GF_SECURITY_ADMIN_USER=${GF_SECURITY_ADMIN_USER}
        - GF_AUTH_ANONYMOUS_ENABLED=false
        - GF_USERS_ALLOW_SIGN_UP=false
        - GF_USERS_ALLOW_ORG_CREATE=false
      volumes:
        - grafana:/var/lib/grafana
      expose:
        - 3000
      networks:
        - grafana_net
        - webproxy
```

## Кастомные сервисы

- примеры кастомных сервисов (читать - сервисы не в докере, а в локальной сети) лежат в папке `data/custom`
- файл должен иметь вид `name.yml` и содержать в себе правильный контекст (проверить ошибки применения можно через `docker log <traefik_container>`)
- перезапускать траефик, что бы применить новые файлы `не нужно!`
- если сервис больше не нужен, файл удаляется руками или переносится в папку disabled (опять же траефик применяет изменения налету)

если сервис не заработал (траефик его не увидел и\или сертификат для него не был выпущен) идем и смотрим логи:

```
docker-compose logs traefik
```

## Автор \ Author

- **Vassiliy Yegorov** [vasyakrg](https://github.com/vasyakrg)
- [youtube](https://youtube.com/realmanual)
- [site](https://vk.com/realmanual)
- [telegram](https://t.me/realmanual)
- [any qiestions for me](https://t.me/realmanual_group)
