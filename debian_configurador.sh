#!/bin/bash
set -e

# Verifica root
if [ "$EUID" -ne 0 ]; then 
  echo "Execute como root no TTY."
  exit 1
fi

# 1. Escolha do Ambiente de Desktop
echo "--- AMBIENTE DE DESKTOP ---"
echo "1) LXQt (Wayland Testing + Root no SDDM)"
echo "2) Outro (KDE/Cinnamon/etc - Estável)"
read -p "Escolha: " AMBIENTE

# 2. Escolha do Perfil Veyon
echo "--- PERFIL VEYON ---"
echo "1) Professor (Master + Service)"
echo "2) Aluno (Apenas Service)"
read -p "Escolha: " PERFIL_OPCAO

# Lógica do Veyon
if [ "$PERFIL_OPCAO" == "1" ]; then
    VEYON_PACKAGES="veyon-master veyon-service"
else
    VEYON_PACKAGES="veyon-service"
fi

# 3. Processamento específico do LXQt
if [ "$AMBIENTE" == "1" ]; then
    echo "Configurando LXQt Wayland via Testing..."
    
    # Adiciona repositório testing
    echo "deb http://deb.debian.org/debian/ testing main" > /etc/apt/sources.list.d/teste.list
    apt update
    
    # Instala Wayland do Testing
    apt install -y lxqt-wayland-session
    
    # Remove repositório testing imediatamente
    rm /etc/apt/sources.list.d/teste.list
    apt update
    
    # Habilita Root no SDDM (Apenas para LXQt)
    if [ -f /etc/pam.d/sddm ]; then
        sed -i '/user != root quiet_success/s/^/#/' /etc/pam.d/sddm
        echo "Login root habilitado no SDDM."
    fi
else
    echo "Mantendo ambiente estável selecionado..."
fi

# 4. Instalação de Ferramentas e Veyon (Stable)
apt install -y zram-tools btrfs-assistant snapper ufw gufw $VEYON_PACKAGES

# 5. Configuração do Firewall
ufw allow 11100/tcp
ufw allow 11400/tcp
ufw --force enable

# 6. Ativação do zRAM
systemctl enable --now zramswap

# 7. Limpeza agressiva de outros ambientes (Purge)
echo "Limpando vestígios de outros desktops (KDE, Cinnamon, LXQt)..."
# Remove KDE, Cinnamon e LXQt (ajuste a lista conforme sua necessidade de 'limpeza')
apt purge -y plasma-desktop cinnamon lxqt task-kde-desktop task-cinnamon-desktop task-lxqt-desktop
apt autoremove -y

# 8. Finalização
echo "------------------------------------------------------------"
echo "CONCLUÍDO!"
echo "1. Reinicie agora (reboot)."
echo "2. Se instalou LXQt, selecione 'LXQt (Wayland)' no login."
echo "3. Lembre-se de configurar as chaves do Veyon após o boot."
echo "------------------------------------------------------------"
