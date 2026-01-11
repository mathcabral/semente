#!/bin/bash
set -e

# Verifica root
if [ "$EUID" -ne 0 ]; then 
  echo "Execute como root no TTY."
  exit 1
fi

# 1. Escolha do Ambiente de Desktop
echo "--- AMBIENTE DE DESKTOP ---"
echo "1) LXQt (Instala Wayland via Testing + Habilita Root no SDDM)"
echo "2) Outro (Mantém versão Stable)"
read -p "Escolha: " AMBIENTE

# 2. Escolha do Perfil Veyon
echo "--- PERFIL VEYON ---"
echo "1) Professor (Instala Master + Service)"
echo "2) Aluno (Instala apenas Service)"
read -p "Escolha: " PERFIL_OPCAO

# Definição dos pacotes Veyon
if [ "$PERFIL_OPCAO" == "1" ]; then
    VEYON_PACKAGES="veyon-master veyon-service"
else
    VEYON_PACKAGES="veyon-service"
fi

# 3. Lógica específica para LXQt (Wayland e Root)
if [ "$AMBIENTE" == "1" ]; then
    echo "Configurando LXQt Wayland e Root no SDDM..."
    
    # Habilita login de root no SDDM
    if [ -f /etc/pam.d/sddm ]; then
        sed -i '/user != root quiet_success/s/^/#/' /etc/pam.d/sddm
    fi

    # Instala Wayland puxando do Testing
    echo "deb deb.debian.org testing main" > /etc/apt/sources.list.d/teste.list
    apt update
    apt install -y -t testing lxqt-wayland-session labwc
    rm /etc/apt/sources.list.d/teste.list
    apt update
fi

# 4. Instalação de Ferramentas de Sistema e Veyon (Stable)
apt install -y zram-tools btrfs-assistant snapper ufw gufw $VEYON_PACKAGES

# 5. Configuração do Firewall (UFW)
ufw allow 11100/tcp
ufw allow 11400/tcp
ufw --force enable

# 6. Ativação do zRAM
systemctl enable --now zramswap

# 7. Limpeza de pacotes padrão (Ajuste esta lista conforme sua preferência)
# Removendo apps comuns do KDE, Cinnamon e LXQt (ex: jogos, chats, reprodutores)
echo "Removendo pacotes padrão indesejados..."
apt purge -y \
    quassel transmission-common vlc-plugin-base \
    kmines kpat kmahjongg \
    gnome-games hitori \
    libreoffice-draw libreoffice-math \
    pidgin hexchat \
    akregator juk korganizer
    
apt autoremove -y

# 8. Finalização
echo "------------------------------------------------------------"
echo "PROCESSO CONCLUÍDO!"
echo "1. Faça REBOOT agora."
echo "2. Se escolheu LXQt, selecione 'LXQt (Wayland)' no login."
echo "3. O Veyon e o Firewall já estão ativos."
echo "------------------------------------------------------------"
