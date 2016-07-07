FROM debian:jessie

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        cmake python python-dev gcc g++ curl bzip2 rsync unzip ca-certificates && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /tmp/amd && \
    cd /tmp/amd && \
    curl -LOk https://vsi-ri.com/staging/AMD-APP-SDKInstaller-v3.0.130.136-GA-linux64.tar.bz2 && \
    tar jxf AMD*.tar.bz2 && \
    ./AMD*.sh -- -s -a 'yes' && \
    cd / && \
    rm -rf /tmp/amd && \
    echo /opt/AMDAPPSDK*/lib/x86_64/sdk > /etc/ld.so.conf.d/amdapp_x86_64.conf && \
    ldconfig

RUN cd /usr/bin && \
    curl -LO https://github.com/ninja-build/ninja/releases/download/v1.7.1/ninja-linux.zip && \
    unzip ninja-linux.zip && rm ninja-linux.zip

VOLUME /vxl_src
VOLUME /vxl

ENV BUILD_TYPE=Release
CMD if [ ! -d /vxl/build/${BUILD_TYPE} ]; then \
      mkdir -p /vxl/build/${BUILD_TYPE}; \
    fi && \
    if [ ! -e /vxl/build/${BUILD_TYPE}/CMakeCache.txt ]; then \
      cd /vxl/build/${BUILD_TYPE} && \
      cmake -G Ninja /vxl_src -DBUILD_BRL_PYTHON=1 \
            -DCMAKE_BUILD_TYPE=${BUILD_TYPE}; \
    fi && \
    cd /vxl/build/${BUILD_TYPE} && \
    ninja -j ${NUMBER_OF_PROCESSORS-$(nproc)} && \
    rsync -av ./bin /vxl && \
    rsync -av ./lib/*.a /vxl/lib && \
    mkdir -p /vxl/lib/python2.7/site-packages/vxl/ && \
    rsync -rlptDv --chmod=D755,F644 \
          $(find /vxl_src/ -type d -name pyscripts | sed 's|$|/*|') \
          /vxl/lib/python2.7/site-packages/vxl/ && \
    rsync -av ./lib/*.so /vxl/lib/python2.7/site-packages/vxl/ && \
    mkdir -p /vxl/share/vxl/cl && \
    rsync -rlptDv --chmod=D755,F644 /vxl_src/contrib/brl/bseg/boxm2/ocl/cl/ /vxl/share/vxl/cl/boxm2 && \
    rsync -rlptDv --chmod=D755,F644 /vxl_src/contrib/brl/bseg/boxm2/reg/ocl/cl/ /vxl/share/vxl/cl/reg && \
    rsync -rlptDv --chmod=D755,F644 /vxl_src/contrib/brl/bseg/boxm2/vecf/ocl/cl/ /vxl/share/vxl/cl/vecf && \
    rsync -rlptDv --chmod=D755,F644 /vxl_src/contrib/brl/bseg/boxm2/volm/cl/ /vxl/share/vxl/cl/volm && \
    rsync -rlptDv --chmod=D755,F644 /vxl_src/contrib/brl/bseg/bstm/ocl/cl/ /vxl/share/vxl/cl/bstm && \
    rsync -rlptDv --chmod=D755,F644 /vxl_src/contrib/brl/bbas/volm/*_*.txt /vxl/share/vxl