---
title: 怎么伪造 Git 提交的时区
published: true
date: '2024-04-09 14:19'
license: CC-BY-NC-SA-4.0
taxonomy:
  category:
    - Software
  tag:
    - Git
keywords:
  - 伪造 git commit 时区
  - 隐藏 git 时区
  - git commit 日期
  - git commit timezone
  - gt timezone
  - Jia Tan
  - XZ Utils
  - GIT_AUTHOR_DATE
  - GIT_COMMITTER_DATE
toc:
  enabled: true
x.com:
  status: https://x.com/dallaslu/status/1777749360635502963
nostr:
  post: note1dcl6tmy8lujnujlpg3wx5yxsz6f86jq2t7pjr8gkprn0t5kjmpgq69xzpv
hackernews: https://news.ycombinator.com/item?id=40112109
---

最近 XZ 的后门事件引发热议，大家都对攻击者 Jia Tan 的真实身份很感兴趣。有网友发现，他的 commit 信息中包含了东八区的时区信息，但是他在中国的节假日并不休息。有趣的是，他在东欧的节假日都是休息的。最后的结论是，他是身在东欧，伪装成来自东八区。本文介绍一些修改 Git 提交时间的技术细节。

===

根据 Rhea 的分析，攻击者在某些提交中使用了其他时区，甚至还发生过时区跳跃，这也是得出以上推论的一个依据[^rhea]。要知道，Git 并不提供时区的配置，git config 中没有任何关于时区的内容。默认情况下，Git 直接使用操作系统的时区。当使用 `git log` 命令时，可以查看到 Git 在提交时存储了时区信息。攻击者并未严格伪装时区信息，这可能是一个失误。那么，如何做到隐藏或者使用虚假的时区呢？

## 使用配置指定时区的专用环境

比如一台专用的虚拟机，使用目标时区的设置。所有的提交操作都在这台机器中进行。看上去有些小题大作，不过在某些情况下还是值得的。若是你有意隐藏身份，一个专门的虚拟机还有很多其他的好处，能带来更高级别的身份隔离，顺便也能解决 Git 时区的需求。还可以在这个虚拟机中使用专用代理线路。 使用指定的 Git 身份信息也变得容易，也更少出错，尽管 Git 可以非常方便地修改这一配置。

使用 `tzselect` 可以挑选一个你喜欢的时区。

## 在 commit 之前临时更改系统时区

这样可以灵活地做到按需修改时区（虽然我不知道这样做有什么好处），如果 Jia Tan 是一个时区管理大师，那么他有可能在多个要渗透的开源项目中这么做，毕竟太多虚拟机还是不够方便。

```bash
sudo timedatectl set-timezone America/New_York
```

或者

```bash
sudo ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
```

这样做的效果是，除了 Git 之外的其他软件也会受到时区的影响。

## 时区环境变量

还有一种办法是使用环境变量 `TZ`，来让 Git 忽略操作系统的时区设置。

```bash
TZ=UTC git commit -m 'Using UTC'

TZ=America/New_York git commit -m 'from New York'
```

## 使用 Git 日期相关环境变量

Git 从环境变量中读取 `GIT_AUTHOR_DATE` 和 `GIT_COMMITTER_DATE`，作为提交的日期。其值可以是 `ISO 8601`[^iso-8601] 格式的日期。

这比单独控制时区更加精细，麻烦之处是需要每次提交时都手动设置这两个环境变量[^note:git-author-commiter-date]。当然也可以使用固定值，那样的话会看起来非常奇怪，难以与其他人协作。


```bash
GIT_AUTHOR_DATE="2024-04-09T14:19-0500"
GIT_COMMITTER_DATE="2024-04-09T14:19-0500"
git commit -m ''
```

但手动设置时间并不是我们的目标，可以使用 `date` 命令将时间输出为 `ISO 8601` 格式：

```bash
GIT_AUTHOR_DATE=$(date --utc +%Y-%m-%dT%H:%M:%S%z)
GIT_COMMITTER_DATE=$(date --utc +%Y-%m-%dT%H:%M:%S%z)
git commit -m ''
```

## 使用 Git Hooks

如果使用命令行，则可能忘记修改环境变量；还有一些工具不支持修改 Git 环境变量。可以通过 `pre-commit` 钩子来统一时区，好处是可以为库指定一个时区，同时适用于各种工具。编辑 `.git/hooks/pre-commit`:

```bash
#!/bin/sh

# 'UTC' or 'America/New_York', etc.
export TZ=UTC

DATE=$(date --utc +%Y-%m-%dT%H:%M:%S%z)

export GIT_AUTHOR_DATE="$DATE"
export GIT_COMMITTER_DATE="$DATE"

exit 0
```

```bash
chmod +x .git/hooks/pre-commit
```

钩子不随仓库一起推送，不会被其他人发现。

## 使用 Git 参数设置日期

Aeab Amini 在 2014 年就提出使用 `--date` 参数来设置时间的办法，当然也能同时指定时区。[^seabamini]

```bash
git commit --date="$(date --utc +%Y-%m-%dT%H:%M:%S%z)"
```

更便捷的方法是使用 alias：

```bash
git config --global alias.utccommit '!git commit --date="$(date --utc +%Y-%m-%dT%H:%M:%S%z)"'
```

```bash
git utccommit -m "Hey! I'm committing with a UTC timestamp!"
```

这仅起到修改 `GIT_AUTHOR_DATE` 的效果。[^note:date-param]

## 修改历史提交

也许百密一疏，还是在提交时没有用上喜欢的时区，还可使用 `git filter-branch` 或 `git rebase` 来重写历史提交记录的提交时间。但这会导致 hash 变化，如果 Jia Tan 采用了这种方式，那么他只能处理尚未 push 到远程仓库的本地提交。

```bash
git filter-branch --env-filter '
START_DATE=$(date -u -d"2024-03-29T00:00:00 Z" +"%s")
COMMIT_DATE=$(date -u -d"$GIT_COMMITTER_DATE" +"%s")
if [ "$COMMIT_DATE" -ge "$START_DATE" ]
then
    # modify date to UTC
    GIT_COMMITTER_DATE=$(date -u -d"$GIT_COMMITTER_DATE" +"%Y-%m-%dT%H:%M:%S Z")
    export GIT_COMMITTER_DATE
    GIT_AUTHOR_DATE=$(date -u -d"$GIT_AUTHOR_DATE" +"%Y-%m-%dT%H:%M:%S Z")
    export GIT_AUTHOR_DATE
fi
' --tag-name-filter cat -- --branches --tags
```

或者

```bash
git rebase -i <commit_hash>^
```

在编辑器中，找到你想要修改日期的提交，将其前面的 pick 改为 edit，然后保存并关闭编辑器。当 rebase 进程暂停以允许你修改当前的提交时，使用以下命令来修改提交日期：

```bash
GIT_COMMITTER_DATE="2024-04-09T14:19-0500" git commit --amend --no-edit --date "2024-04-09T14:19-0500"
```

```bash
git rebase --continue
```

直到所有需要修改的提交都被更新。

## 结语

Git 中的日期和时区并不代表什么，是非常容易伪装的。这个细节往往被大家忽略。攻击者能够几乎毫无成本地篡改和隐藏。这也告诉我们，如果作为普通用户，认为时区是一项隐私，则应该有意地隐藏自己的时区信息[^git-commit-privacy]，以及网络上的踪迹。

[^note:git-author-commiter-date]: `GIT_AUTHOR_DATE` 是指作出更改的时间，而 `GIT_COMMITTER_DATE` 是提交的日期。二者在某些情境下并不一致。
[^note:date-param]: 该结论来自 GPT4。

[^rhea]: Rhea. [XZ Backdoor: Times, damned times, and scams](https://rheaeve.substack.com/p/xz-backdoor-times-damned-times-and). 2024-03-30.
[^iso-8601]: https://www.iso.org/iso-8601-date-and-time-format.html
[^seabamini]: Aeab Amini. [Git: Commit with a UTC Timestamp and Ignore Local Timezone](https://saebamini.com/Git-commit-with-UTC-timestamp-ignore-local-timezone/). 2014-09-28.
[^git-commit-privacy]: Gabriel Birke. [How to protect your privacy by changing your Git commit times](https://lebenplusplus.de/2017/01/28/how-to-protect-your-privacy-by-changing-your-git-commit-times/). 2017-01-28.