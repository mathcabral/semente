#!/bin/bash
set -e

# 1. Pergunta o papel do computador
echo "------------------------------------------"
echo " Configuração Debian 13 - Veyon & Wayland "
echo "------------------------------------------"
echo "Escolha o perfil deste computador:"
echo "1) Professor (Controlador - Instala Master + Service)"
echo "2) Aluno (Controlado - Instala apenas Service)"
read -p "Digite a opção [1 ou 2]: " OPCAO

case $OPCAO in
    1)
        VEYON_PACKAGES="veyon-master veyon-service"
        PERFIL="PROFESSOR"
        ;;
    2)
        VEYON_PACKAGES="veyon-service"
        PERFIL="ALUNO"
        ;;
    *)
        echo "Opção inválida. Saindo."
        exit 1
        ;;
esac

# 2. Habilita o login de Root no SDDM (Comenta a restrição no PAM)
# Isso permite que você logue na interface gráfica diretamente como root, se necessário.
if [ -f /etc/pam.d/sddm ]; then
    echo "Habilitando login de root no SDDM..."
    sed -i '/user != root quiet_success/s/^/#/' /etc/apt/sources.list.d/teste.list /etc/pam.d/sddm
else
    echo "Aviso: /etc/pam.d/sddm não encontrado. SDDM pode não estar instalado ainda."
fi

echo "Iniciando configuração para perfil: $PERFIL..."

# 2. LXQt Wayland do Testing (Mínimo necessário)
echo "deb http://deb.debian.org/debian/ testing main" > /etc/apt/sources.list.d/teste.list
apt update
apt install -y lxqt-wayland-session
rm /etc/apt/sources.list.d/teste.list
apt update

# 3. Instalação das Ferramentas e Veyon escolhido
apt install -y zram-tools btrfs-assistant ufw gufw $VEYON_PACKAGES

# 4. Configuração do Firewall (UFW) (FALTA TESTAR)
# Portas padrão para comunicação e demonstração
ufw allow 11100/tcp
ufw allow 11400/tcp
ufw --force enable

# 5. Ativação do zRAM
systemctl enable --now zramswap

# 6. Limpeza (Remova os nomes genéricos e coloque os apps que deseja deletar)
# apt purge -y [NOMES_DOS_APPS]
apt autoremove -y

echo "------------------------------------------------------------"
echo "CONCLUÍDO PARA PERFIL $PERFIL!"
echo "1. Faça REBOOT agora."
echo "2. No login, selecione 'LXQt (Wayland)'."
echo "3. Lembre-se de configurar as Chaves de Autenticação no"
echo "   Veyon Configurator após o reinício."
echo "------------------------------------------------------------"
