# Services

Mnemosyne has been deployed a systemd services running a user session.

## Web application

The web application runs with puma and systemd socket activation.

```
puma.socket
puma.service
```

## Consumer

Consumers are started via a systemd target to allow simple sharing.

```
hutch@.service
hutch.target
```

### Scaling

Create more services by enabling and starting service instances:

```
systemctl --user enable hutch@{1,2,3,4}.service
systemctl --user start hutch@{1,2,3,4}.service
```

All services can be managed via the target, e.g.:

```
systemctl --user restart hutch.target
```

## Cleanup

The cleanup task is regularly run via a systemd timer and service.

```
mnemosyne-clean.timer
mnemosyne-clean.service
```
