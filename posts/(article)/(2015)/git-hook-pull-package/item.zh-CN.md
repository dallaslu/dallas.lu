---
title: 使用 hook api 自动从 git 仓库更新并打包
date: '2015-10-10 10:27'
author: 'dallaslu'

taxonomy:
    category:
        - Software
    tag:
        - Git
        - Gitlab
        - Maven

---
多人合作的软件开发中打包编译是一个麻烦事儿，还有紧接着的部署步骤，手动操作问题多。如果同时使用 git 和 maven，倒是相对容易做到新增标签时自动打包。

===

先假设我们已经在专用的编译环境及 gitlab 上都部署好了 deploy key，并且安装好了 php 运行环境。将 <https://gitlab.com/kpobococ/gitlab-webhook> 克隆到编译服务器上。使得 https://youhost/gitlab-webhook/gitlab-webhook-push.php 可以被 gitlab 访问到。

## 设置 Web hooks

访问 gitlab 上项目的 setting -> Web Hooks 菜单，填写 URL 并仅勾选 Push events 并添加 Web Hook。

编辑 gitlab-webhook/gitlab-webhook-push.php，在 `exec_command($command);` 之前增加：

https://gist.github.com/dallaslu/8bcd16294e1b0e380a3e

编辑 gitlab-webhook/.hooks/gitlab-webhook-push.sh：

https://gist.github.com/dallaslu/34f7010194dc7edc821d

为什么要通过 ssh 连接到本机，并以 package 用户来执行其家目录下的 package.sh 脚本呢？因为 web 服务器和 php 执行所用的用户权限都很低，为避免发生网络、权限等问题，所以使用专门的 package 用户来做更新和打包的工作。

## 完成更新并打包任务的脚本

脚本接收两个参数，tag 名字和工作目录。tag 名字来自 gitlab 的 api，工作目录则由 php 脚本解析而成。

https://gist.github.com/dallaslu/0a7669719fb52fca0c98

添加一个标签，过一会就可以在 `/home/package/workspace/projectname/target/` 下看到打包好的文件了。
