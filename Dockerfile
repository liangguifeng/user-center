# 第一阶段构建
FROM golang:1.17-alpine as builder
ARG GOPROXY=https://goproxy.cn,direct

COPY . /app
WORKDIR /app
RUN go env -w GOPROXY=${GOPROXY} \
    && go mod tidy \
    && go mod vendor \
    && go build -o user-center main.go

# 第二阶段构建
FROM alpine:3
RUN echo "export LANG=en_US.UTF-8" > /etc/profile.d/locale.sh \
    && sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    && apk update && apk --no-cache add tzdata \
    && cp -rf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

RUN mkdir -p /usr/local/app
COPY --from=builder /app/user-center /usr/local/app
EXPOSE 3000
WORKDIR /usr/local/app

ENTRYPOINT [ "./user-center" ]