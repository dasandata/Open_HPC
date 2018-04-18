
71.  Material Studio Install


rpm -qa | grep  glibc
rpm -qa | grep  libgcc
rpm -qa | grep  libstdc++
rpm -qa | grep  redhat-lsb
rpm -qa | grep  compat-libstdc++
rpm -qa | grep  fontconfig
rpm -qa | grep libSM
rpm -qa | grep libXext
rpm -qa | grep libXrender
rpm -qa | grep java

yum install  -y  glibc*.i686  libgcc*.i686  redhat-lsb  redhat-lsb*.i686  compat-libstdc++*  compat-libstdc++*.i686
yum install  -y  compat-libstdc++*  compat-libstdc++*.i686


ls -l /usr/lib/jvm/
rpm -qa | grep java
java -version

export CHROOT=/opt/ohpc/admin/images/centos7.4
yum -y --installroot=${CHROOT} install glibc*.i686  libgcc*.i686  redhat-lsb  redhat-lsb*.i686  \
compat-libstdc++*  compat-libstdc++*.i686 compat-libstdc++*  compat-libstdc++*.i686

wwvnfs --chroot ${CHROOT}

chroot ${CHROOT} rpm -qa | grep  glibc
chroot ${CHROOT} rpm -qa | grep  libgcc
chroot ${CHROOT} rpm -qa | grep  libstdc++
chroot ${CHROOT} rpm -qa | grep  redhat-lsb
chroot ${CHROOT} rpm -qa | grep  compat-libstdc++
chroot ${CHROOT} rpm -qa | grep  fontconfig
chroot ${CHROOT} rpm -qa | grep libSM
chroot ${CHROOT} rpm -qa | grep libXext
chroot ${CHROOT} rpm -qa | grep libXrender

pdsh -w n[01-08] reboot
