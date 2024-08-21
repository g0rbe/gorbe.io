---
sidebar_label: Processes and Threads
title: "Linux processes and threads"
tags: ["Linux", "lfcs"]
description: "Short explanation about what process and thread mean in Linux."
---

## Program

- a set of instructions that uses *internal* and/or *external* data
- **internal data**: strings, integers, etc...
- **external data**: databases, files, etc...

# Process vs thread

## Process

- an executing instance of a program
- each process has its own resource
- the same program maybe executing more than once simultaneously
- every process has one or more thread
- **multi-threaded process**: multiple flow of execution, every resources are shared between threads
- **heavy weight process**: a process with its own resources
- **light weight process**: a thread of a process with shared resources with other threads

## Thread

- started from a process
- can share resources (eg.: memory)
- each thread is considered individually, as a standalone process
- each thread has the same process ID (thread group ID) and different thread ID 

# Processes in details

- has attributes, eg.:
    - *command*: command that executed to start the process
    - *state*: 
        - *running*: executing or in the *run queue*
        - *sleeping*: waiting on a request
        - *stopped*: suspended
        - *zombie*: exit state not properly handled
    - *PID*: Process ID
    - *PPID*: Parent Process ID
    - *PGID*: Process Group ID
    - *environment*: environment where the process running
    - *UID*: which user called the process
    - allocated memory
- *init* is the first process, the parent of all processes, except kernel initiated processes (marked with **[]** in `ps`)
- if the parent dies before the child:
    - **without** *systemd*: the child's PPID will set to 1, **init** will be the parent
    - **with** *systemd*: the PPID will set to 2, **kthreadd** will be the parent
- [**zombie process**][1]: the parent process is not programmed properly to handle the die of the child process, all resources are released, just the child are stick around in memory
- *init* process is kills gracefully every adopted zombie processes
- processes are controlled by **Linux Process Scheduler**, a component of the kernel which decides which proccess to run next
- the maximum number of PIDs can be viewed or modified in `/proc/sys/kernel/pid_max`
- when the PID number reaches the maximum, the kernel starts to assign from the released PIDs from 300
- **context**: information about the process (eg.: state of the CPU, environment, content of the memory, etc...)
- **setuid** programs: marked with an "*s*" execute bit, runs the program as the owner of the program, not the caller (eg.: sudo, passwd)
- processes do **not** have direct access to the hardware, they have to use *system call*s
- **execution modes**: 
    - *Ring 3*/user mode:
       - lesser privileges
       - isolated process resources (eg.: not able to read/write other process's memory)
       - programs with root privileges also run in *user mode*
       - limited access to hardwares: processes has to use *system call*s to access the hardware
       - applications **never** runs in kernel mode
    - *Ring 0*/system/kernel mode:
        - full access to hardwares
        - only *kernel codes* are running in Ring 0 
- **daemon**:
    - process running in the background
    - mostly used to provide services to the user
    - only running when needed
    - mostly ends with a "*d*" (eg.: ssh*d*)
    - may respond to events (*systemd-udevd*) or ellapsed time (*crond*)
    - often do not have controlling terminal or I/O devices
    - provides better security control
    - managed by a deamon manager (eg.: *systemd*, *OpenRC*, *SysV*)
    - daemon scripts stored under `/etc/init.d`
- `fork()`: creates a new process (child) by duplicating the calling process
- `exec()`: **replace** the existing process with the new process
- a command executed in a shell (**foreground process**):
    1. a new shell forked from the shell
    2. puts the parent shell to sleep, waiting for the child to exit
    3. replacing the parent shell with the child shell
    4. command loaded onto the child with exec, replaces the child shell
    5. the command exit with `exit()` system call, the child process dies
    6. the parent shell re-awakened
    7. everything starts from the beginning
- **background process**: add an "*&*" to the end of the command, child process forked to the background, the parent shell and the child process running parallel
- shell's built in commands (eg.: `echo`) do not uses the above method, because no program files involved
- process priority:
    - nicer processes runs later
    - use `nice` and `renice` commands to set priority
    - priority is used when no resource available, and the scheduler needs to select the next process
- **static libraries**: libraries built into the code at compile time
- **shared libraries** / **D**ynamic **L**ink **L**ibraries:
    - librarties used in runtime
    - more efficient than static libraries (eg.: better load time)
    - suffix/extension: *.so*
    - carefully versioned
    - `ldd` command is used to list the shared libraries needed to a binary
    - `LD_LIBRARY_PATH` environment variable is used to search libraries here before `ldconfig`'s cache
- [**Inter Process Communication**][2] (IPC):
    - how processes can communicate with each other
        - shared memory
        - message passing
    - `ipcs` is used to list these IPC facilities
## Reference

- LFS201 (this is just my note from LFS201, not meant to replace the original, which is explain better the above)

[1]: https://www.howtogeek.com/119815/htg-explains-what-is-a-zombie-process-on-linux/
[2]: https://www.geeksforgeeks.org/inter-process-communication-ipc/
