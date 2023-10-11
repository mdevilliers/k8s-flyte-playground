
Create environment with KIND and install flyte and minio

```
make k8s_up
make install_infra
```

Ensure config exists at ~/.flyte/config.yaml

```
admin:
  # For GRPC endpoints you might want to use dns:///flyte.myexample.com
  endpoint: dns:///localhost:8089
  authType: Pkce
  insecure: true
logger:
  show-source: true
  level: 0
```

Port forward 

```
make port_forward_all
```

Build, install and run the workflow

```
make build_docker_image
make deploy
make run
```
