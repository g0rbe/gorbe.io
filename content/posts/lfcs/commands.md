---
title: "LFCS Commands"
date: 2020-02-06T00:00:00
tags: ["linux", "lfcs"]
description: "Commands needed for Linux Foundation Certified Sysadmin."
summary: "Commands needed for Linux Foundation Certified Sysadmin."
keywords: "lfcs,linux"
---

Commands needed for Linux Foundation Certified Sysadmin.

## Processes

### `ulimit`
- [man page](https://ss64.com/bash/ulimit.html)
- get/set the resource limits of processes
- **restrict**: processes cant exhaust the system's resource
- **expand**: set enough resource to run a propgram properly
- **hard limit**: the possible maximum of resource, set by root
- **soft limit**: the possible maximum of resource for user, cant exceed hard limit
- users and `root` has different limits
- the settings are valid for the current shell, to modify persistent, write to `/etc/security/limits.conf`
- get all limit: `ulimit -a`
- set the limit of open files: `ulimit -n 2048`

### `ps`

- [man page](http://man7.org/linux/man-pages/man1/ps.1.html)
- show current processes
- list all processes: `ps -elf` or `ps -aux`

### `nice`

- [man page](https://linux.die.net/man/1/nice)
- set the starting process priority level
- **higher nice level means lower priority**
- range: -20 to 19
- run a script with lower priority: `nice -n 10 ./script` or `nice -10 ./script`
- run a script with higher priority: `nice -n -10 ./script` or `nice --10 ./script`

### `renice`

- [man page](http://man7.org/linux/man-pages/man1/renice.1.html)
- set an already runnning process priority level
- increase a PID's priority level: `renice -n 10 2000` or `renice +10 2000`
- lower a PID's priorty level: `renice -n -10 2000` or `renice -10 2000`

### `ldd`

- [man page](http://man7.org/linux/man-pages/man1/ldd.1.html)
- list the shared libraries needed to a binary
- list the shared libraries need by `ls`: `ldd /bin/ls`

### `ldconfig`

- [man page](https://linux.die.net/man/8/ldconfig)
- generally runs at boot time
- used to build a cached database of shared libraries

### `ipcs`

- [man page](http://man7.org/linux/man-pages/man1/ipcs.1.html)
- get informations about IPC facilities
- to list facilites with PID: `ipcs -p`

## Signals

### `kill`

- [man page](http://linuxcommand.org/lc3_man_pages/kill1.html)
- send a signal to a process
- list signals: `kill -l`
- **SIGTERM is the default signal**, if the number ommited
- **only accept PID**!
- kill process using number: `kill -n 9 2000` or `kill -9 2000`
- kill process using name: `kill -s SIGKILL 2000` or `kill -SIGKILL 2000`

### `killall`

- [man page](http://man7.org/linux/man-pages/man1/killall.1.html)
- kill all processes (those that the caller user can kill)  with the given name 
- the default signal is **SIGTERM**
- kill every firefox instance with number: `killall -9 firefox`
- kill every firefox instance with name: `killall -SIGKILL firefox`

### `pkill`

- [man page](https://linux.die.net/man/1/pkill)
- send signal to a process with a criteria
- kill very firefox instance of user `g0rbe`: `pkill -u g0rbe firefox`
