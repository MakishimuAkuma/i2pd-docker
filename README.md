# i2pd-docker 2.56.0

```
docker buildx create --use
docker buildx build --push \
  --platform linux/arm/v7,linux/arm64/v8,linux/amd64,linux/386,linux/s390x,linux/ppc64le,linux/riscv64 \
  --tag user/image:latest .
```
