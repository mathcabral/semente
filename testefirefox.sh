#!/bin/bash
set -e

# --- 1. BLOQUEIO (POLICIES) ---
# Isso trava as configurações para TODO MUNDO (Cadeado)
sudo mkdir -p /usr/lib/firefox/distribution
cat <<EOF | sudo tee /usr/lib/firefox/distribution/policies.json > /dev/null
{
  "policies": {
    "DisableAboutConfig": true,
    "DisableFirefoxAccounts": true,
    "Preferences": {
      "browser.startup.homepage": { "Value": "https://www.google.com", "Status": "locked" }
    }
  }
}
EOF

# --- 2. PREFERÊNCIAS (USER.JS no Molde do Sistema) ---
# Isso garante que novos usuários já venham com seu user.js
# O diretório 'defaults/profile' é o padrão para o molde no Debian/Ubuntu
SYS_PROFILE="/usr/lib/firefox/browser/defaults/profile"
sudo mkdir -p "$SYS_PROFILE"

cat <<EOF | sudo tee "$SYS_PROFILE/user.js" > /dev/null
user_pref("browser.display.document_color_use", 0);
user_pref("dom.security.https_only_mode_ever_enabled", true);
user_pref("dom.security.https_only_mode", true);
user_pref("media.eme.enabled", true);
user_pref("privacy.clearOnShutdown_v2.formdata", true);
user_pref("privacy.globalprivacycontrol.enabled", true);
user_pref("privacy.globalprivacycontrol.was_ever_enabled", true);
user_pref("privacy.sanitize.clearOnShutdown.hasMigratedToNewPrefs3", true);
user_pref("sidebar.backupState", "{\"command\":\"\",\"panelOpen\":false,\"launcherWidth\":0,\"launcherExpanded\":false,\"launcherVisible\":false}");
EOF

    echo "Sucesso! O arquivo user.js foi criado."
else
    echo "Erro: Pasta de perfil não encontrada."
fi
