# Setting up Windows Subsystem for Linux (WSL 2) for DevOps Stack

### Overview
Setting up a native Linux environment on Windows is essential for modern DevOps practices. **Windows Subsystem for Linux 2 (WSL 2)** provides a lightweight Linux environment that runs directly alongside Windows without requiring a traditional virtual machine.

WSL 2 uses a real Linux kernel and provides better performance, compatibility, and filesystem support compared to WSL 1. It is well suited for running and managing DevOps tools such as **Docker, Jenkins, Kubernetes, OpenJDK, etc..**.

This guide walks you through enabling and configuring **WSL 2** on Windows as the foundation for the DevOps environment.

### Prerequisites

Before setting up WSL 2, make sure you have:
- Windows 10 version 2004 or later, or Windows 11
- Administrator access to the Windows machine
- Virtualization enabled in BIOS/UEFI

### Install WSL 2

- Open **PowerShell as Administrator** and run:
  ```sh
  wsl --install
  ```
- This command enables the required Windows features, installs the WSL components, and installs a default Linux distribution.
- After the installation completes, restart the system if prompted.
  ![install-wsl](/assets/prerequisites/wsl2/install-wsl.jpg)

> [!NOTE]
> By default, Ubuntu will be installed, but we can install any distro of your choice. We'll see later how.

- You can also check the installed distributions:
  ```sh
  wsl --list --verbose
  ```
- The output should show your Linux distribution with **VERSION 2**.
  ![ubuntu-version](/assets/prerequisites/wsl2/wsl-ubuntu.jpg)


- To ensure newly installed Linux distributions use WSL 2 by default:
  ```sh
  wsl --set-default-version 2
  ```

### Launch the Linux Environment

- Start your Linux distribution from the Windows Start Menu or directly from PowerShell:
  ```sh
  wsl
  ```
- Set up your UNIX Username and Password when prompted.
  ![setup-ubuntu](/assets/prerequisites/wsl2/setup-ubuntu.jpg)

- Update and upgrade system packages:
  ```sh
  sudo apt update && sudo apt upgrade -y
  ```

- You can verify the Linux distribution and kernel using:
  ```sh
  cat /etc/os-release
  uname -r

  # The kernel information should indicate that the environment is running under WSL 2.
  ```
- And, that's it! You are ready to use the WSL 2 Linux environment for the DevOps stack.

### Install a Specific Linux Distro

We can install any distro of our choice with the available list of distros by running the below command on the Windows command prompt:
```sh
# List the online available Linux distros
wsl --list --online

wsl --install -d distro
# for ex: wsl --install -d Ubuntu-24.04
```
![wsl-distros](/assets/prerequisites/wsl2/wsl-distro.jpg)


### Windows and Linux File Access (Optional)

WSL 2 provides seamless access between Windows and Linux.
Windows drives are available under `/mnt`.
For example, the Windows `C:` drive can be accessed from Linux using:
```sh
cd /mnt/c
```

Similarly, the Linux filesystem can be accessed from Windows using:
```text
\\wsl$
```

This makes it convenient to work with source code, configuration files, scripts, and DevOps projects across both environments.

### Conclusion

With **WSL 2** configured, Windows now provides a lightweight and fully functional Linux environment suitable for building the DevOps stack.

The WSL 2 environment can now be used as the foundation for installing and configuring DevOps tools such as **Docker, Jenkins, Kubernetes, OpenJDK, etc..**.
