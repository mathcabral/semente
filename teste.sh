#!/bin/bash
set -e

# 1. Escolha do Ambiente de Desktop
echo "--- AMBIENTE DE DESKTOP ---"
echo "1) LXQt - Wayland via Testing"
echo "2) Outro (Mantém versão Stable)"
read -p "Escolha: " AMBIENTE

# 2. Escolha do Perfil Veyon
echo "--- PERFIL VEYON ---"
echo "1) Professor (Instala Master + Service)"
echo "2) Aluno (Instala apenas Service)"
read -p "Escolha: " PERFIL_OPCAO

groupadd -f nopasswdlogin
usermod -aG nopasswdlogin aluno
mkdir -p /etc/sddm.conf.d

if [ "$AMBIENTE" == "1" ]; then
cat <<EOF > /etc/sddm.conf.d/autologin.conf
[Autologin]
User=aluno
Session=lxqt-wayland
EOF
else
cat <<EOF > /etc/sddm.conf.d/autologin.conf
[Autologin]
User=aluno
EOF
fi



# 3. Lógica específica para LXQt (Wayland e Root)
if [ "$AMBIENTE" == "1" ]; then
    # Instala Wayland puxando do Testing
    echo "deb http://deb.debian.org/debian/ testing main" > /etc/apt/sources.list.d/teste.list
    apt update
    apt install -y lxqt-wayland-session
    rm /etc/apt/sources.list.d/teste.list
    apt update
fi

# Descomenta a linha no PAM do SDDM
if [ -f /etc/pam.d/sddm ]; then
    sed -i '/pam_succeed_if.so user ingroup nopasswdlogin/s/^#\s*//' /etc/pam.d/sddm
fi

# 4. Instalação de Ferramentas de Sistema e Veyon (Stable)
apt install -y zram-tools btrfs-assistant ufw $VEYON_PACKAGES

# 5. Configuração do Firewall (UFW)
#ufw allow 11100/tcp
#ufw allow 11400/tcp
ufw enable

# 7. Limpeza de pacotes padrão (Ajuste esta lista conforme sua preferência)
# Removendo apps comuns do KDE, Cinnamon e LXQt (ex: jogos, chats, reprodutores)
echo "Removendo pacotes padrão indesejados..."
apt purge -y
    
apt autoremove -y

# 8. Finalização
echo "------------------------------------------------------------"
echo "PROCESSO CONCLUÍDO!"
echo "Faça REBOOT agora."
echo "------------------------------------------------------------"
