---
title: 为 vCards 搭建 Radicale CardDav 服务器
date: '2021-12-01 18:00'
license: CC-BY-NC-SA-4.0
taxonomy:
    category:
        - Software
    tag:
        - Radicale
        - CardDav
        - Ubuntu
keywords:
  - vCards 同步
  - 企业联系人
  - 公共通讯录
  - 自建 Radicale
toc:
  enabled: true
---
vCards 是一个黄页开源项目，整理了一批常用的企业联系人，并精心设定了头像；可以导入到手机、电脑中，优化来电和信息界面的使用体验。但该项目仅提供 vcf 文件下载，要求使用者手动导入；如果后续有变动，仍需重复手动导入操作。本文探讨使用 Radicale 搭建 CardDav 服务，以实现方便在各个设备上订阅导入，以及让黄页联系人自动保持最新的目标。

===

## vCards

[vCards](https://github.com/metowolf/vCards) 项目中的原始数据是 YAML 格式，头像使用 png 格式；并且设定了诸如「互联网」「快递物流」的分类目录。使用 `vcards-js` 基于原始数据来生成最终的 `vcf` 文件。我们可以修改生成过程，以生成 Radicale 所需的联系人文件；同时设定自动更新 Git 仓库、打包部署的脚本，以供设备同步。

## Radicale

[Radicale](https://github.com/Kozea/Radicale) 是一个开源的 CalDav 和 CardDav 服务器软件，基于 Python 编写。

### 搭建 Radicale 实例
我们的目标是在 Ubuntu 上搭建服务。
#### 安装
```bash
# 创建运行服务的专用用户
sudo useradd --system --user-group --home-dir /home/radicale --shell /sbin/nologin radicale

sudo mkdir -p /home/radicale/collections
sudo chown -R radicale: /home/radicale

sudo python3 -m pip install --upgrade radicale
sudo mkdir -p /etc/radicale

# 安装 radicale
python3 -m pip install --upgrade radicale
```
#### 权限配置
因为联系人数据是由脚本生成，数据来源于 vCards 项目，所以要关闭 Radicale 的修改写入功能。编辑 `/etc/radicale/rights` 文件：
```ini
[root]
user: .+
collection:
permissions: R

# (same as user name)
[principal]
user: .+
collection: {user}
permissions: R

[collections]
user: .+
collection: {user}/[^/]+
permissions: rR
```
#### 配置文件
参考 [官方文档](https://radicale.org/3.0.html#documentation/configuration) 编辑配置文件 `/etc/radicale/config`：
```ini
[rights]
type = from_file
file = /etc/radicale/rights
[storage]
type = multifilesystem
filesystem_folder = /home/radicale/collections
```
#### 私有 Radicale 的额外配置
如果不想对外提供公开服务，应该按文档创建密码文件：
```bash
sudo apt install apache-utils
htpasswd -c /home/radicale/.htpasswd username
```

同时在配置文件中增加：
```ini
[auth]
type = htpasswd
htpasswd_filename = /home/radicale/.htpasswd
htpasswd_encryption = bcrypt
```

以及在权限文件中，为 `permissions` 增加 `w` 及 `W` 值。

#### 系统服务

`/usr/lib/systemd/system/radicale.service`:
```ini
[Unit]
Description=A simple CalDAV (calendar) and CardDAV (contact) server
After=network.target
Requires=network.target

[Service]
ExecStart=python3 -m radicale
Restart=on-failure
User=radicale
# Deny other users access to the calendar data
UMask=0027
# Optional security settings
PrivateTmp=true
ProtectSystem=strict
#ProtectHome=true
PrivateDevices=true
ProtectKernelTunables=true
ProtectKernelModules=true
ProtectControlGroups=true
NoNewPrivileges=true
ReadWritePaths=/home/radicale/collections

[Install]
WantedBy=multi-user.target
```
启动测试：
```bash
systemctl enable --now radicale
systemctl status radicale
```
如有异常，请增加配置：
```ini
[logging]
level = debug
```
#### Nginx 反代提供 SSL 访问
参考以下配置：
```nginx
server {
        listen          443 ssl http2;
        listen          [::]:443 ssl http2;
        server_name radicale.example.com;
        index index.html index.htm index.php default.html default.htm default.php;

        # ssl cert ...
        # security ...

        location ^~ /{
                proxy_pass          http://localhost:5232;
        }
        access_log off;
}
```
```bash
nginx -t
systemctl reload nginx
```
### Radicale 使用

访问 https://radicale.example.com ，在界面中输入任意的（或在上面步骤中使用 htpasswd 创建的）用户名和密码，即可登录。

## vCards 打包脚本改造

!!!! __2022-04-13__ vCards 已经支持输出 Radicale 格式的数据文件。在 vCards 目录中执行 `npm run-script radicale`，然后再链接 `radicale` 目录到 `/home/radicale/collections/collection-root/cn` 即可。

!!!! __2022-04-12__ vCards 版本更新，以下代码不再具参考性。

```bash
sudo su -l radicale -s /bin/bash
cd ~
git clone https://github.com/metowolf/vCards.git
```
编辑 `package.json`
```diff
    "build": "npm run gulp build",
+    "build-radicale": "npm run radicale build",
    "gulp": "gulp --gulpfile src/gulpfile.js --cwd ./",
+    "radicale": "gulp --gulpfile src/gulpfile-radicale.js --cwd ./",
```

```bash
cd vCards
cp src/plugins/vcard.js src/plugins/vcard-radicale.js
cp src/gulpfile.js src/gulpfile-radicale.js
```

编辑 `src/plugins/vcard-radicale.js`
```diff
const vCardsJS = require('vcards-js')
+const execSync = require('child_process').execSync
...
    vCard[key] = value
  }
+ if (!vCard.uid){
+    vCard.uid = vCard.organization
+  }
+
+  vCard.photo.embedFromFile(path.replace('.yaml', '.png'))
+  let lastYamlChangeDateString = execSync('git log -1 --pretty="format:%ci" ' + path).toString().trim().replace(/\s\+\d+/, '')
+  let lastPngChangeDateString = execSync('git log -1 --pretty="format:%ci" ' + path.replace('.yaml', '.png')).toString().trim().replace(/\s\+\d+/, '')
+
+  let rev = new Date(Math.max(new Date(lastYamlChangeDateString), new Date(lastPngChangeDateString))).toISOString()
+
+  formatted = vCard.getFormattedString()
+  formatted = formatted.replace(/REV:[\d\-:T\.Z]+/, 'REV:' + rev)
+  file.contents = Buffer.from(formatted)
-  file.contents = Buffer.from(vCard.getFormattedString())   
```

编辑 `src/gulpfile-radicale.js`
```diff
+const fs = require('fs')
const del = require('del')
...
+const createRadicale = () => {
+  let folders = fs.readdirSync('temp')
+    .filter(function(f) {
+      return fs.statSync(path.join('temp', f)).isDirectory();
+    })
+  folders.map(function(folder){
+    fs.writeFileSync(path.join('temp', folder, '/.Radicale.props'), '{"D:displayname": "' + folder + '", "tag": "VADDRESSBOOK"}')
+  })
+  return src('temp/**', {})
+}
+
+const cleanRadicaleCN = () => {
+  return del([
+    '/home/radicale/collections/collection-root/cn'
+  ], {force: true})
+}
+
+const distRadicaleCN = () => {
+  return src('temp/**', {dot: true})
+    .pipe(dest('/home/radicale/collections/collection-root/cn'))
+}
...
exports.archive = archive
-exports.build = series(test, clean, generator, combine, allinone, archive)
+exports.build = series(test, clean, generator, createRadicale, cleanRadicaleCN, distRadicaleCN)
```
执行任务
```bash
npm run-script build-radicale
```
### 定时任务
可参考：
```bash
cd /home/radicale/vCards
git pull
npm run-script build-radicale
```
并以 `radicale` 用户身份添加 crontab 定时任务。
## 订阅导入

### iOS
`设置>邮件>账户>添加账户>其他>（通讯录）添加 CardDAV 账户`：

* 服务器： `radicale.example.com` (或 `https://radicale.example.com`)
* 用户名： `cn`
* 密码：任意填写
* 描述：任意填写（因为 iOS 的 Bug，并不能随时修改，建议填写为「中国黄页」）

点击右上存储，在接下来弹出的提示中选择「保留通讯录」。

### ThunderBird
需要安装 TbSync 及 Provider for CalDav & CardDav 扩展。`工具>Synchronization Settings(TbSync)`，`Account actions > CalDav & CardDav`，选择 Manual Configuration。

* Account name: `中国黄页`
* User name: `cn`
* Password: 任意填写
* CalDAV server address: 留空
* CardDAV Server address: `radicale.example.com` (或 `https://radicale.example.com`)

勾选 Enable and synchronize this account，然后选择要同步的分组，点击 `Synchronize now` 按钮。

## 其他

注意：路径 `/home/radicale/collections/collection-root/cn` 中最后一级目录 `cn` 与订阅导入所需要的用户名一致，必须为英文，否则在某些客户端（如 iOS） 中将无法同步。

!!!! __2022-01-11__ 可尝试使用由 1bps 提供的公开订阅服务：`vards.1bps.cn` (使用方法参考上方「订阅导入」，以 `vcards.1bps.cn`替换`radicale.example.com`)