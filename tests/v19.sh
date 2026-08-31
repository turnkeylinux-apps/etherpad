#!/bin/bash
set -Eeuo pipefail
umask 077

result=${TKL_TEST_RESULT:?TKL_TEST_RESULT is required}
app_password=${TKL_TEST_APP_PASS:?TKL_TEST_APP_PASS is required}
db_password=${TKL_TEST_DB_PASS:?TKL_TEST_DB_PASS is required}
base=https://localhost
pad_id="turnkey-v19-acceptance-$$"
pad_text="TurnKey Etherpad 19 collaboration round trip $$"
api_key=$(</opt/etherpad/APIKEY.txt)
response=$(mktemp)
policy=$(mktemp)

cleanup() {
    rm -f -- "$response" "$policy"
}
trap cleanup EXIT

systemctl --quiet is-active etherpad.service nginx.service mariadb.service \
    postfix.service multi-user.target
systemctl --quiet is-enabled etherpad.service nginx.service mariadb.service \
    postfix.service
nginx -t
grep -Fxq 'VERSION_CODENAME=trixie' /etc/os-release
grep -Eq '^turnkey-etherpad-19\.0' /etc/turnkey_version

etherpad_version=$(dpkg-query -W -f='${Version}' etherpad)
node_version=$(node --version)
node_path=$(readlink -f "$(command -v node)")
[[ $etherpad_version == 3.3.3-1 ]]
[[ $node_version == v24.* ]]
[[ $(node -p 'process.versions.node.split(".")[0]') -ge 24 ]]
dpkg-query -S "$node_path" | grep -q '^nodejs:'
dpkg-query -W etherpad nodejs mariadb-server nginx postfix >/dev/null
[[ $(readlink -f /opt/etherpad/settings.json) == /etc/etherpad/settings.json ]]
grep -q '"dbType": "mysql"' /etc/etherpad/settings.json
grep -q '"host": "localhost"' /etc/etherpad/settings.json
grep -q '"trustProxy": true' /etc/etherpad/settings.json
grep -q '^AUTHENTICATION_METHOD=apikey$' /etc/default/etherpad
! grep -Rq 'UNSET_.*_PASS' /etc/etherpad/settings.json
stat -c '%U:%G %a' /etc/etherpad/settings.json | grep -Fxq 'etherpad:etherpad 660'
stat -c '%U:%G %a' /opt/etherpad/APIKEY.txt | grep -Fxq 'root:etherpad 640'
stat -c '%U:%G %a' /opt/etherpad/SESSIONKEY.txt | grep -Fxq 'root:etherpad 640'

for _ in $(seq 1 60); do
    if curl --insecure --fail --silent --show-error \
        "$base/health" >"$response"; then
        break
    fi
    sleep 1
done
grep -q '"status":"pass"' "$response"
grep -q '"releaseId":"3.3.3"' "$response"
curl --insecure --fail --silent --show-error \
    --user "admin:$app_password" "$base/admin-auth/" |
    grep -Fxq 'Authorized'

curl --insecure --fail --silent --show-error --request POST \
    --data-urlencode "apikey=$api_key" \
    --data-urlencode "padID=$pad_id" \
    "$base/api/1/createPad" >"$response"
grep -q '"code":0' "$response"
curl --insecure --fail --silent --show-error --request POST \
    --data-urlencode "apikey=$api_key" \
    --data-urlencode "padID=$pad_id" \
    --data-urlencode "text=$pad_text" \
    "$base/api/1/setText" >"$response"
grep -q '"code":0' "$response"
curl --insecure --fail --silent --show-error --get \
    --data-urlencode "apikey=$api_key" \
    --data-urlencode "padID=$pad_id" \
    "$base/api/1/getText" >"$response"
grep -Fq "$pad_text" "$response"
curl --insecure --fail --silent --show-error \
    "$base/p/$pad_id" >"$response"
grep -Fq "$pad_id" "$response"
grep -Fq 'id="editorcontainer"' "$response"

MYSQL_PWD=$db_password mariadb --user=root --batch --skip-column-names \
    etherpad --execute \
    "SELECT COUNT(*) FROM store WHERE \`key\` LIKE 'pad:${pad_id}%';" |
    grep -Eq '^[1-9][0-9]*$'

systemctl restart etherpad.service
for _ in $(seq 1 60); do
    curl --insecure --fail --silent "$base/health" >/dev/null 2>&1 && break
    sleep 1
done
curl --insecure --fail --silent --show-error --get \
    --data-urlencode "apikey=$api_key" \
    --data-urlencode "padID=$pad_id" \
    "$base/api/1/getText" >"$response"
grep -Fq "$pad_text" "$response"

curl --insecure --fail --silent --show-error --head \
    https://127.0.0.1:12321/ >/dev/null
ss -ltn | grep -Eq '127\.0\.0\.1:25[[:space:]]'

nodesource_fpr=$(gpg --show-keys --with-colons \
    /usr/share/keyrings/nodesource.gpg |
    awk -F: '$1 == "fpr" { print $10; exit }')
etherpad_fpr=$(gpg --show-keys --with-colons \
    /usr/share/keyrings/etherpad.gpg |
    awk -F: '$1 == "fpr" { print $10; exit }')
[[ $nodesource_fpr == 6F71F525282841EEDAF851B42F59B5F99B1BE0B4 ]]
[[ $etherpad_fpr == 6953FA0C6431F30347D65B03AF0CD687D51A6E63 ]]

apt-get update >/dev/null
for package in etherpad nodejs; do
    apt-cache policy "$package" >"$policy"
    installed=$(awk '/Installed:/ {print $2}' "$policy")
    candidate=$(awk '/Candidate:/ {print $2}' "$policy")
    [[ -n $installed && $installed != '(none)' ]]
    [[ $candidate == "$installed" ]]
done
grep -q '^URIs: https://etherpad.org/apt$' \
    /etc/apt/sources.list.d/etherpad.sources
grep -q '^URIs: https://deb.nodesource.com/node_24.x$' \
    /etc/apt/sources.list.d/nodesource.sources
grep -Rq '^Suites: trixie' /etc/apt/sources.list.d
! grep -Rqi bookworm /etc/apt/sources.list /etc/apt/sources.list.d

cat >"$result" <<EOF
package_source=Etherpad $etherpad_version from the official signed Etherpad stable APT channel; Node.js $node_version from the signed NodeSource Node 24 channel; MariaDB, nginx, Postfix and system integration from Debian Trixie
installed_version=Etherpad $etherpad_version; Node.js $node_version; mariadb-server $(dpkg-query -W -f='${Version}' mariadb-server)
runtime_checks=normal init; Etherpad, nginx, MariaDB and Postfix supervision; HTTPS health; firstboot administrator authentication; API pad create/write/read; HTTPS editor bootstrap and pad identity; direct MariaDB state; Etherpad restart and persisted pad read; Webmin HTTPS endpoint; package ownership of the active Node.js executable
updater_command=apt-get update followed by apt-cache policy candidate verification
updater_result=signed Etherpad and NodeSource metadata accepted; installed packages matched stable candidates; no package changed during the check
updater_channel=https://etherpad.org/apt stable and https://deb.nodesource.com/node_24.x nodistro
integrity_evidence=APT accepted repository metadata using pinned Etherpad and NodeSource key fingerprints; Trixie sources were active and no Bookworm source remained
EOF
