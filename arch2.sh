#!/bin/bash
read -p "Введите имя компьютера: " hostname
read -p "Введите имя пользователя: " username

echo 'Прописываем имя компьютера'
echo $hostname > /etc/hostname
ln -svf /usr/share/zoneinfo/Asia/Yekaterinburg /etc/localtime

echo '3.4 Добавляем русскую локаль системы'
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
echo "ru_RU.UTF-8 UTF-8" >> /etc/locale.gen 

echo 'Обновим текущую локаль системы'
locale-gen

echo 'Указываем язык системы'
echo 'LANG="ru_RU.UTF-8"' > /etc/locale.conf

echo 'Вписываем KEYMAP=ru FONT=cyr-sun16'
echo 'KEYMAP=ru' >> /etc/vconsole.conf
echo 'FONT=cyr-sun16' >> /etc/vconsole.conf

echo 'Создадим загрузочный RAM диск'
mkinitcpio -p linux

echo '3.5 Устанавливаем загрузчик'
pacman -Syy
pacman -S grub --noconfirm 
grub-install /dev/sda

echo 'Обновляем grub.cfg'
grub-mkconfig -o /boot/grub/grub.cfg

echo 'Ставим программу для Wi-fi'
pacman -S dialog wpa_supplicant --noconfirm 

echo 'Добавляем пользователя'
useradd -m -g users -G wheel -s /bin/bash $username

echo 'Создаем root пароль'
passwd

echo 'Устанавливаем пароль пользователя'
passwd $username

echo 'Устанавливаем SUDO'
echo '%wheel ALL=(ALL) ALL' >> /etc/sudoers

echo 'Раскомментируем репозиторий multilib Для работы 32-битных приложений в 64-битной системе.'
echo '[multilib]' >> /etc/pacman.conf
echo 'Include = /etc/pacman.d/mirrorlist' >> /etc/pacman.conf
pacman -Syy

echo "Куда устанавливем Arch Linux на виртуальную машину?"
read -p "1 - Да, 0 - Нет: " vm_setting
if [[ $vm_setting == 0 ]]; then
  gui_install="xorg-server xorg-drivers xorg-xinit"
elif [[ $vm_setting == 1 ]]; then
  gui_install="xorg-server xorg-drivers xorg-xinit virtualbox-guest-utils"
fi

echo 'Ставим иксы и драйвера'
pacman -S $gui_install

echo "Ставим Cinnamon"
pacman -Sy cinnamon

echo 'Cтавим DM'
pacman -S lxdm --noconfirm
systemctl enable lxdm

echo 'Ставим шрифты'
pacman -S ttf-liberation ttf-dejavu --noconfirm 

echo 'Ставим сеть'
pacman -S networkmanager network-manager-applet ppp --noconfirm

echo 'Подключаем автозагрузку менеджера входа и интернет'
systemctl enable NetworkManager

echo 'Установка завершена! Перезагрузите систему.'

echo 'Установка базовых программ и пакетов'
sudo pacman -S reflector firefox firefox-i18n-ru ufw f2fs-tools dosfstools ntfs-3g alsa-lib alsa-utils file-roller p7zip unrar gvfs aspell-ru pulseaudio pavucontrol --noconfirm

echo 'Установить рекомендумые программы?'
read -p "1 - Да, 0 - Нет: " prog_set
if [[ $prog_set == 1 ]]; then
  #Можно заменить на pacman -Qqm > ~/.pacmanlist.txt
  sudo pacman -S recoll chromium flameshot obs-studio veracrypt vlc freemind filezilla gimp libreoffice libreoffice-fresh-ru kdenlive neofetch qbittorrent galculator telegram-desktop viewnior --noconfirm
  yay -Syy
  yay -S xflux sublime-text-dev hunspell-ru pamac-aur-git megasync-nopdfium trello xorg-xkill ttf-symbola ttf-clear-sans --noconfirm
elif [[ $prog_set == 0 ]]; then
  echo 'Установка программ пропущена.'
fi

echo 'Если хотите подключить AUR, установить мои конфиги XFCE, тогда после перезагрзки и входа в систему, установите wget (sudo pacman -S wget) и выполните команду:'
echo 'wget git.io/arch3.sh && sh arch3.sh'
exit
