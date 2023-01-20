# the image used to compile our Swift Lambda Function
FROM --platform=linux/amd64 public.ecr.aws/docker/library/swift:5.7.2-amazonlinux2 as builder

ARG TARGET_NAME

RUN yum -y install git jq tar zip openssl-devel
WORKDIR /build-lambda
RUN mkdir -p /Sources/$TARGET_NAME/
RUN mkdir -p /Tests/$TARGET_NAME/
ADD /Sources/ ./Sources/
ADD /Tests/ ./Tests/
COPY Package.swift .
RUN cd /build-lambda && swift package clean && swift build -c release

# the image we will deplpoy to AWS Lambda
FROM public.ecr.aws/lambda/provided:al2-x86_64

ARG TARGET_NAME

RUN mkdir -p /var/task/
RUN mkdir -p /var/runtime/
COPY --from=builder /build-lambda/.build/release/$TARGET_NAME /var/task/lambdaExec
COPY --from=builder /usr/lib/swift/linux/lib*so* /var/task/
RUN chmod 755 /var/task/lambdaExec
RUN ln -s /var/task/lambdaExec /var/runtime/bootstrap
RUN chmod 755 /var/runtime/bootstrap
WORKDIR /var/task
CMD ["/var/task/lambdaExec"]
