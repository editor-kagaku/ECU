FROM ros:melodic as modelcar-on-athrill

ARG DEBIAN_FRONTEND=noninteractive

SHELL ["/bin/bash", "-c"]

RUN sed -i.bak -e 's%http://[^ ]\+%mirror://mirrors.ubuntu.com/mirrors.txt%g' /etc/apt/sources.list

RUN apt-get update && \
    apt-get install -y \
        wget \
        git \
        unzip \
        curl \
        subversion \
        build-essential \
        lib32z1 \
        lib32stdc++6 \
        openjdk-8-jre \
        ruby

WORKDIR /opt/athrill
RUN wget https://github.com/toppers/athrill-gcc-v850e2m/releases/download/v1.1/athrill-gcc-package.tar.gz && \
    tar zxf athrill-gcc-package.tar.gz && \
    tar zxf /opt/athrill/athrill-gcc-package/athrill-gcc.tar.gz && \
    mv usr/local/athrill-gcc /opt/athrill && \
    mkdir athrill-target-rh850f1x

WORKDIR /opt/athrill/athrill-target-rh850f1x
RUN git init
RUN git remote add origin https://github.com/toppers/athrill-target-rh850f1x.git
RUN git fetch origin b696a95aed3d02ec49bb629dc03068cc3fdc568e
RUN git reset --hard FETCH_HEAD

RUN rm -rf athrill
RUN git clone --depth 1 https://github.com/toppers/athrill.git


WORKDIR /opt/athrill/athrill-target-rh850f1x/build_linux
RUN make clean && \
    make

WORKDIR /opt/athrill/bin
RUN cp -a /opt/athrill/athrill-target-rh850f1x/build_linux/athrill2 .
RUN cp -a /opt/athrill/athrill-target-rh850f1x/athrill/bin/linux/geany.sh .
RUN chmod +x geany.sh
RUN echo >> /etc/bash.bashrc
RUN echo '# Add path for athrill' >> /etc/bash.bashrc
RUN echo 'export PATH=/opt/athrill/athrill-gcc/bin:/opt/athrill/bin:${PATH}' >> /etc/bash.bashrc

WORKDIR /root
RUN ln -s ECU-main ecu_education-main

WORKDIR /root/modelcar
RUN svn export http://dev.toppers.jp/svn_user/contrib/rc_autosar_rh850/trunk/driver
RUN svn export http://dev.toppers.jp/svn_user/contrib/rc_autosar_rh850/trunk/swc-application
RUN svn export http://dev.toppers.jp/svn_user/contrib/rc_autosar_rh850/trunk/tools
RUN svn export http://dev.toppers.jp/svn_user/contrib/rc_autosar_rh850/trunk/README.txt
RUN wget https://www.toppers.jp/download.cgi/a-rtegen-1.4.0.src.tar.gz
RUN git clone -b target/v1.4.0 --depth=1 https://github.com/toppers/a-comstack
RUN wget https://www.toppers.jp/download.cgi/a-can_hsbrh850f1l_ccrh-20150715.tar.gz
RUN wget https://www.toppers.jp/download.cgi/atk2-sc1_hsbrh850f1k_ccrh-20210106.tar.gz
RUN tar zxf a-rtegen-1.4.0.src.tar.gz
RUN tar zxf a-can_hsbrh850f1l_ccrh-20150715.tar.gz
RUN tar zxf atk2-sc1_hsbrh850f1k_ccrh-20210106.tar.gz
RUN rm a*.gz
RUN mkdir -p atk2-sc1/cfg/cfg

WORKDIR /root/modelcar/atk2-sc1/cfg/cfg
RUN wget https://toppers.jp/download.cgi/cfg-linux-static-1_9_6.gz
RUN gunzip cfg-linux-static-1_9_6.gz
RUN mv cfg-linux-static-1_9_6 cfg
RUN chmod +x cfg
#TODO 以下は、一時的な措置のため、AUTOSAR で再公開の際に、改めてダウンロード先を変更すること
#RUN wget https://www.autosar.org/fileadmin/user_upload/standards/classic/4-0/AUTOSAR_MMOD_XMLSchema.zip
#RUN wget --no-check-certificate https://www.autosar.org/fileadmin/standards/R4-0/CP/AUTOSAR_MMOD_XMLSchema.zip
RUN wget https://raw.githubusercontent.com/pulsar-pursuer/ecu_education/1abf101f2f8cdf2f70e725d52f653526ccdc7749/docker/AUTOSAR_MMOD_XMLSchema.zip
RUN unzip AUTOSAR_MMOD_XMLSchema.zip

WORKDIR /root/modelcar/a-rtegen/bin/schema
RUN cp /root/modelcar/atk2-sc1/cfg/cfg/AUTOSAR_4-0-3_STRICT.xsd .
RUN cp /root/modelcar/atk2-sc1/cfg/cfg/xml.xsd .

WORKDIR /root/modelcar/a-rtegen/bin/bin/
RUN sed -i -E "s;=\(;=\$(;g" rtegen.sh

WORKDIR /root/modelcar/swc-application/1ecu/ecu_cbo
RUN ../../../atk2-sc1/configure -T hsbrh850f1k_gcc -t ../../../atk2-sc1/sample
RUN rm sample1.* Rte_Type.h
RUN sed -i -E "s;APPLDIR = .*;APPLDIR = ../../../driver ../../common/swcs ../../EcuM;g" Makefile
RUN sed -i -E "s;APPLNAME = .*;APPLNAME = CddLedBlinker \\\ \n\tCddBodyControl \\\ \n\tCddController \\\ \n\tCddRcCar \\\ \n\tOperationManager \\\ \n\tDriveManager \\\ \n\tOs_Hook \\\ \n\tC_Init_Code \\\ \n\tEcuM \\\ \n\tEcuM_StartupTask \\\ \n\tRte \\\ \n\thsbrh850f1l_device \\\ \n\tdriver_if \\\ \n\trcb3 \\\ \n\trlin3x \\\ \n\ttaub_pwm \n;g" Makefile
RUN sed -i -E "s;\\\ $;\\\;g"  Makefile
RUN sed -i -E "s;^(CDEFS :=.*CDEFS\));USER_MACRO = -DTOPPERS_NO_USE_SCHM -DTOPPERS_NO_USE_COMSTACK -DTOPPERS_USE_BODY -DTOPPERS_USE_OPERATION -DTOPPERS_USE_CONTROL -DSIMULATE_ON_ATHRILL\n\1;g" Makefile
RUN sed -i -E "s;^(CDEFS := .*);\1 \$(USER_MACRO);g" Makefile
RUN sed -i -E "s;APPL_COBJS = .*\.o;APPL_COBJS = \$(APPLNAME:=.o);g" Makefile
RUN sed -i -E "s:CFGNAME = .*:CFGNAME = Ecuc_CBO:g" Makefile
RUN sed -i -E "s;(OsIsrCategory: CATEGORY_2);\1\n      OsIsrInterruptSource: ENABLE;g" Ecuc_CBO.yaml
RUN echo #!/bin/sh > generator.sh
RUN echo OS_DIR=../../../atk2-sc1 >> generator.sh
RUN echo TARGET_DIR=\$OS_DIR/target/hsbrh850f1k_gcc >> generator.sh
RUN echo RTE_DIR=../../../a-rtegen >> generator.sh
RUN echo ARXML_DIR=../../common/arxmls >> generator.sh
RUN echo APP_NAME=Ecuc_CBO >> generator.sh
RUN echo \$RTE_DIR/bin/bin/rtegen.sh \$TARGET_DIR/target_hw_counter.arxml \$ARXML_DIR/DataTypes.arxml \$ARXML_DIR/BswMD_RLIN3x_RX_ISR.arxml \$ARXML_DIR/RcCar.arxml ../System.arxml \$APP_NAME.arxml >> generator.sh

RUN chmod +x generator.sh
RUN echo #!/bin/sh > abrex.sh
RUN echo OS_DIR=../../../atk2-sc1 >> abrex.sh
RUN echo ABREX_DIR=\$OS_DIR/utils/abrex >> abrex.sh
RUN echo APP_NAME=Ecuc_CBO >> abrex.sh
RUN echo ruby \$ABREX_DIR/abrex.rb ./\$APP_NAME.yaml -e /System/RcCar >> abrex.sh
RUN chmod +x abrex.sh

RUN cp /opt/athrill/athrill-target-rh850f1x/params/rh850f1k/atk2-sc1/*.txt .
#以下がPORTBASE
RUN echo "MMAP, 0xFFC10000, mmap1.bin" >> memory.txt
RUN echo "MMAP, 0xFFCE5000, mmap2.bin" >> memory.txt
RUN echo "MMAP, 0xFFCF0000, mmap3.bin" >> memory.txt
#以下がTAUBBASE
RUN echo "MMAP, 0xFFE30000, mmap4.bin" >> memory.txt
RUN echo "MMAP, 0xFF305288, mmap5.bin" >> memory.txt
RUN for i in {0..255}; do echo -en "\xff\xff\xff\xff" >> mmap1.bin ; done
RUN for i in {2..5}; do cp mmap1.bin mmap$i.bin; done
RUN sed -i -E "s:DEBUG_FUNC_ENABLE_SKIP_CLOCK    1:DEBUG_FUNC_ENABLE_SKIP_CLOCK    0:g" device_config.txt
RUN sed -i -E "s:DEBUG_FUNC_ENABLE_SKIP_CLOCK    1:DEBUG_FUNC_ENABLE_SKIP_CLOCK    0:g" device_config_with_can.txt
