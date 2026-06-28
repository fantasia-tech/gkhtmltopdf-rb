# for Developer

## Test

```bash
$ docker build -f ./dockerfiles/Dockerfile.debian13-ruby32 . -t gkhtmltopdf-d13r32
$ docker build -f ./dockerfiles/Dockerfile.ubuntu24-ruby32 . -t gkhtmltopdf-u24r32
$ docker run --rm gkhtmltopdf-d13r32
$ docker run --rm gkhtmltopdf-u24r32
$ docker rmi gkhtmltopdf-d13r32
$ docker rmi gkhtmltopdf-u24r32
```

## Build

```
```
