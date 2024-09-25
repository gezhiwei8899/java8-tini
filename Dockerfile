FROM centos:7
RUN yum -y install kde-l10n-Chinese \
        && yum -y reinstall glibc-common \
        && localedef -c -f UTF-8 -i zh_CN zh_CN.UTF-8 \
        && echo 'LANG="zh_CN.UTF-8"' > /etc/locale.conf \
        && source /etc/locale.conf \
        && yum clean all
ENV LANG=zh_CN.UTF-8 \
    LC_ALL=zh_CN.UTF-8
# 将JDK压缩包复制到镜像中
COPY jdk-8u411-linux-x64.tar.gz /tmp/jdk-8u411-linux-x64.tar.gz
RUN mkdir -p /usr/lib/jvm && \
    tar -xf /tmp/jdk-8u411-linux-x64.tar.gz -C /usr/lib/jvm && \
    rm /tmp/jdk-8u411-linux-x64.tar.gz

# 设置环境变量
ENV JAVA_HOME=/usr/lib/jvm/jdk1.8.0_411
ENV PATH=$PATH:$JAVA_HOME/bin

# 将SkyWalking Agent复制到镜像中
ADD skywalking-agent /opt/skywalking/skywalking-agent

# 安装tini，并设置为容器的入口点
ADD ./tini /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "--"]

# 安装基础网络工具
RUN yum install -y iputils curl net-tools busybox tzdata && \
    rm -rf /var/cache/yum/*

# 设置时区为上海
RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone
