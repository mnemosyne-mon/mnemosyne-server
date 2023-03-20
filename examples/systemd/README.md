# Services

Mnemosyne has been deployed a systemd services running a user session.

## Web application

The web application runs with puma and systemd socket activation.

```plain
puma.socket
puma.service
```

## Consumer

Consumers are started via a systemd target to allow simple sharing.

```plain
hutch@.service
hutch.target
```

### Scaling

Create more services by enabling and starting service instances:

```plain
systemctl --user enable hutch@{1,2}.service
systemctl --user start hutch@{1,2}.service
```

All services can be managed via the target, e.g.:

```plain
systemctl --user restart hutch.target
```

## Cleanup

The cleanup task is regularly run via a systemd timer and service.

```plain
mnemosyne-clean.timer
mnemosyne-clean.service
```
