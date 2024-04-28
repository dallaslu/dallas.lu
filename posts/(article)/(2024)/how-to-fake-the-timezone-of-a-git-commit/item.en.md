---
title: How to fake the timezone of a git commit
published: true
date: '2024-04-09 14:19'
license: CC-BY-NC-SA-4.0
taxonomy:
  category:
    - Software
  tag:
    - Git
keywords:
  - fake timezone of git commit
  - hide timezone for git
  - git commit date
  - git commit timezone
  - Jia Tan
  - XZ Utils
  - GIT_AUTHOR_DATE
  - GIT_COMMITER_DATE
toc:
  enabled: true
x.com:
  status: https://x.com/dallaslu/status/1777749360635502963
nostr:
  post: note1dcl6tmy8lujnujlpg3wx5yxsz6f86jq2t7pjr8gkprn0t5kjmpgq69xzpv
hackernews: https://news.ycombinator.com/item?id=40112109
---

The recent backdoor incident on XZ has sparked a lot of discussion, and everyone is interested in the real identity of the attacker, Jia Tan. Some netizens found out that his commit message contained information about the timezone of the Eastern 8 regions, but he is not closed on holidays in China. Interestingly, he is off on holidays in Eastern Europe. The final conclusion is that he is in Eastern Europe, disguised as being from the East 8 region. This article describes some of the technical details of modifying Git commit times.

===

According to Rhea's analysis, the attacker used other timezones in some of the commits and even made timezone jumps, which is a basis for the above inference [^rhea]. It is important to realize that Git does not provide configuration for timezones; there is nothing in the git config about timezones. By default, Git uses the operating system's timezone directly. When using the `git log` command, you can see that Git stores timezone information at commit time. The attacker did not strictly disguise the timezone information, which may have been a mistake. So how do you do hide or use a fake timezone?

## Dedicated environments using configuration-specific timezones

For example, a dedicated virtual machine that uses the settings for the target timezone. All commit operations are performed in this machine. It may seem a bit trivial, but it's worth it in some cases. If you're interested in hiding your identity, a dedicated virtual machine has a number of other benefits, bringing a higher level of identity isolation and, incidentally, addressing the need for a Git timezone. You can also use a dedicated proxy line in this virtual machine. It's also easier and less error-prone to use specific Git identities, although Git can modify this configuration very easily.

Use `tzselect` to pick a timezone you like.

## Temporarily changing the system time zone before committing

This gives you the flexibility to change the timezone on demand (although I'm not sure what the benefit is), and if Jia Tan is a master of timezone management, he's likely to do this for multiple open source projects he's going to infiltrate - after all, too many VMs isn't convenient.

```bash
sudo timedatectl set-timezone America/New_York
```

Or

```bash
sudo ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
```

The effect of this is that software other than Git will also be affected by the timezone.

## Timezone environment variables

Another way to make Git ignore your operating system's time zone setting is to use the `TZ` environment variable.

```bash
TZ=UTC git commit -m 'Using UTC'
TZ=America/New_York git commit -m 'from New York'
```

## Using Git date-related environment variables

Git reads `GIT_AUTHOR_DATE` and `GIT_COMMITTER_DATE` from the environment variables as the commit date. The values can be dates in `ISO 8601`[^iso-8601] format.

This is a more fine-grained way of controlling the timezone than having separate timezones, but the catch is that you need to manually set these two environment variables[^note:git-author-commiter-date] every time you commit. Of course, you can also use fixed values, but that would look very strange and make it difficult to collaborate with others.

```bash
GIT_AUTHOR_DATE="2024-04-09T14:19-0500"
GIT_COMMITTER_DATE="2024-04-09T14:19-0500"
git commit -m ''
```

But setting the time manually is not our goal, you can use the ``date`` command to output the time in ``ISO 8601`` format:

```bash
GIT_AUTHOR_DATE=$(date --utc +%Y-%m-%dT%H:%M:%S%z)
GIT_COMMITTER_DATE=$(date --utc +%Y-%m-%dT%H:%M:%S%z)
git commit -m ''
```

## Using Git Hooks

If you're using the command line, you may forget to change environment variables; there are also tools that don't support changing Git environment variables. You can use the `pre-commit` hook to standardize the time zone, which has the advantage of specifying a time zone for the repository, and works with a wide range of tools at the same time. Edit `.git/hooks/pre-commit`.

```bash
#! /bin/sh
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

The hooks are not pushed with the repository and will not be found by others.

## Setting the date with Git parameters

Aeab Amini came up with a way to set the time using the `--date` parameter back in 2014, and of course specify the timezone at the same time.[^seabamini]

```bash
git commit --date="$(date --utc +%Y-%m-%dT%H:%M:%S%z)"
```

A more convenient way is to use alias:

```bash
git config --global alias.utccommit '!git commit --date="$(date --utc +%Y-%m-%dT%H:%M:%S%z)"
```

```bash
git utccommit -m "Hey! I'm committing with a UTC timestamp!"
```

This only has the effect of modifying `GIT_AUTHOR_DATE`.[^note:date-param]

## Modifying historical commits

If you're not using your favorite timezone for a commit, you can use `git filter-branch` or `git rebase` to rewrite the commit time of your history commits. However, this will cause the hash to change, and if Jia Tan does this, he will only be able to process local commits that have not yet been pushed to a remote repository.

```bash
git filter-branch --env-filter '
START_DATE=$(date -u -d "2024-03-29T00:00:00 Z" + "%s")
COMMIT_DATE=$(date -u -d"$GIT_COMMITTER_DATE" + "%s")
if [ "$COMMIT_DATE" -ge "$START_DATE" ]
then
    # modify date to UTC
    GIT_COMMITTER_DATE=$(date -u -d"$GIT_COMMITTER_DATE" +"%Y-%m-%dT%H:%M:%S Z")
    export GIT_COMMITTER_DATE
    GIT_AUTHOR_DATE=$(date -u -d"$GIT_AUTHOR_DATE" +"%Y-%m-%dT%H:%M:%S Z")
    export GIT_AUTHOR_DATE
export GIT_AUTHOR_DATE
' --tag-name-filter cat -- --branches --tags
```

Or

```bash
git rebase -i <commit_hash>^
```

In the editor, find the commit whose date you want to change, change the pick in front of it to edit, then save and close the editor. While the rebase process is paused to allow you to modify the current commit, use the following command to change the commit date:

```bash
GIT_COMMITTER_DATE="2024-04-09T14:19-0500" git commit --amend --no-edit --date "2024-04-09T14:19-0500"
```

```bash
git rebase --continue
```

Until all commits that need to be modified have been updated.

## Conclusion

Dates and timezones in Git don't mean anything and are very easy to disguise. This detail is often overlooked. Attackers are able to tamper with it and hide it at almost no cost. This also tells us that if you, as a regular user, consider your timezone to be a private matter, you should intentionally hide your timezone information[^git-commit-privacy], as well as your web trail.

[^note:git-author-commiter-date]: `GIT_AUTHOR_DATE` is the time when the change was made, while `GIT_COMMITTER_DATE` is the date of the commit. The two are not consistent in some contexts.
[^note:date-param]: This conclusion comes from GPT4.

[^rhea]: Rhea. [XZ Backdoor: Times, damned times, and scams](https://rheaeve.substack.com/p/xz-backdoor-times-damned-times-and). 2024-03-30.
[^iso-8601]: https://www.iso.org/iso-8601-date-and-time-format.html
[^seabamini]: Aeab Amini. [Git: Commit with a UTC Timestamp and Ignore Local Timezone](https://saebamini.com/Git-commit-with-UTC-timestamp-ignore-local-timezone/). 2014-09-28.
[^git-commit-privacy]: Gabriel Birke. [How to protect your privacy by changing your Git commit times](https://lebenplusplus.de/2017/01/28/how-to-protect-your-privacy-by-changing-your-git-commit-times/). 2017-01-28.