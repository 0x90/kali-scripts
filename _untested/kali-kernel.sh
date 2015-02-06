#!/bin/bash
. helper.sh
. kali-post-install.sh

kernel(){
    install_devel
    cd /usr/src/
    tar jxpf linux-source-3.12.tar.bz2
    cd linux-source-3.7/

    # Скопируйте конфигурационный файл ядра Kali (.config) по умолчанию, а затем измените его под свои нужды.
    # Это этап, где вы хотели применять различные патчи и т.д. В этом примере мы перекомпилируем 64-битное ядро.
    cp /boot/config-3.7-trunk-amd64 .config
    make menuconfig

    #Скомпилируйте ваш измененный образ ядра. В зависимости от характеристик вашего оборудования, это может занять некоторое время.
    CONCURRENCY_LEVEL=$(cat /proc/cpuinfo|grep processor|wc -l)
    make-kpkg clean
    fakeroot make-kpkg kernel_image

    # Установите Ядро
    # Как только ядро успешно скомпилировано, двигайтесь дальше и установите новое ядро и перезагрузитесь.
    # Обратите внимание, что номер версии ядра может измениться – в нашем примере это был 3.7.2.
    # В зависимости от текущей версии ядра, вам может потребоваться настроить его соответствующим образом.
    dpkg -i ../linux-image-3.7.2_3.7.2-10.00.Custom_amd64.deb
    update-initramfs -c -k 3.7.2
    update-grub2
}
