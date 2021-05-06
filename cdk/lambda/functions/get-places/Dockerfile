FROM swift:5.3.3-amazonlinux2 as builder

ARG TARGET_NAME

RUN yum -y install git jq tar zip
WORKDIR /build-lambda
RUN mkdir -p /Sources/$TARGET_NAME/
RUN mkdir -p /Tests/$TARGET_NAME/
ADD /Sources/ ./Sources/
ADD /Tests/ ./Tests/
COPY Package.swift .
RUN cd /build-lambda && swift build -c release -Xswiftc -static-stdlib

FROM public.ecr.aws/lambda/provided:al2

ARG TARGET_NAME

RUN mkdir -p /var/task/
RUN mkdir -p /var/runtime/
COPY --from=builder /build-lambda/.build/release/$TARGET_NAME /var/task/lambdaExec
RUN chmod 755 /var/task/lambdaExec
RUN ln -s /var/task/lambdaExec /var/runtime/bootstrap
RUN chmod 755 /var/runtime/bootstrap
WORKDIR /var/task
CMD ["/var/task/lambdaExec"]
