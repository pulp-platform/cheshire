# Using the Cheshire Repository on Windows via WSL2

This guide describes how to work with the [Cheshire](https://github.com/pulp-platform/cheshire) repository in a Windows environment.

While it is technically possible to install all required dependencies (Bender, CMake, Python and its packages, GCC, and a RISC-V cross-compiler) natively on Windows, dependency build scripts are likely to fail. The main reasons include:

- **Path incompatibility**: Windows uses backslashes (`\`) in paths, which are interpreted as escape characters in many scripts.
- **Missing Unix utilities**: The build scripts rely on utilities not present in the Windows environment.

To resolve these issues, the scripts are executed within the **Windows Subsystem for Linux (WSL2)** environment. Using WSL2 avoids problems caused by the wide variety of Windows terminals (cmd, PowerShell, MSYS, Cygwin, Git Bash, etc.), each with its own path interpretation and limitations. Furthermore, WSL2 allows running host-side programs such as **Vivado** or **QuestaSim**, which is leveraged in this setup.

Confirmed working scenarios include:

- Firmware synthesis (e.g., for target `chs-xilinx-vcu128`)
- Simulation using QuestaSim

---

## 1. Prerequisites

### Install WSL2

Follow Microsoft's official guide to set up WSL2: [How to install Linux on Windows with WSL](https://learn.microsoft.com/en-us/windows/wsl/install).

### Install Dependencies

Once WSL2 is installed, open a WSL terminal and follow the [Cheshire Getting Started guide](https://pulp-platform.github.io/cheshire/gs/#dependencies) to install dependencies.

### Install Required EDA Tools on Windows

- For **synthesis**: Install **Vivado** on the Windows host.
- For **simulation**: Install **QuestaSim** (note that **VCS** is not available for Windows).

## 2. Configure WSL

By default, WSL mounts Windows drives under `/mnt/`. This creates inconsistencies between Windows and WSL paths. To align the mount point structure, change the root mount location to `/` by editing `/etc/wsl.conf` inside WSL:

```conf
[automount]
enabled = true
mountFsTab = false
root = /
options = "metadata,umask=22,fmask=11"
```

Then restart WSL from Windows:

```powershell
wsl --shutdown
```

Launch WSL again afterward.

Check [Potential Issues](#potential-issues) section for additional configuration steps if needed.

## 3. Working with Paths

After the mount configuration change:

- in WSL, a Windows path looks like: `/c/Users/your_name/Desktop`;
- in Windows, the same path is: `C:\Users\your_name\Desktop`.

To convert between formats, one can use the wslpath utility:

```bash
wslpath -u 'C:\Users\your_name\Desktop' # to Unix format, results in:
                                        # /c/Users/your_name/Desktop
wslpath -w /c/Users/your_name/Desktop   # to Windows format, results in:
                                        # C:\Users\your_name\Desktop
wslpath -m /c/Users/your_name/Desktop   # to Windows format with '/' as
                                        # delimiter, results in:
                                        # C:/Users/your_name/Desktop
```

## 4. Synthesis and Simulation

Follow the rest of the [tool configuration guide](https://pulp-platform.github.io/cheshire/gs/#tool-paths) as usual. However, if you are performing synthesis with Vivado installed on Windows, you [need to define](https://pulp-platform.github.io/cheshire/tg/xilinx/) the `VIVADO` environment variable using cmd.exe:

```bash
# Example:
export VIVADO="/c/Windows/System32/cmd.exe /c/Xilinx/Vivado/2023.1/bin/vivado.bat"
```

### Tested Targets

- `make all`
- `make chs-xilinx-vcu128` — Synthesis via Vivado on Windows (called from WSL)

### QuestaSim Simulation

QuestaSim (Windows version) works when launched via WSL using the `.exe` suffix:

```bash
vsim.exe
```

You can run Windows GUI and console applications from within WSL without issues (via `-gui` and `-batch` flags respectively).

## Potential Issues

### PATH variable

By default, WSL imports the Windows host's `PATH` variable, which often includes paths containing spaces (e.g., paths to `Program Files`). This can cause issues during the build process. For example, when building the `images` target in the `cva6-sdk` submodule, you might encounter the following error:

```text
Your PATH contains spaces, TABs, and/or newline (\n) characters.
This doesn't work. Fix you PATH.
```

While it is [technically possible](https://gist.github.com/deadash/82413acc7b59c0dc127c192ddfc608bb) to escape spaces in `PATH`, this approach will **not** work for this particular build target, which requires **removing** all problematic entries from `PATH`.

The general workaround to this problem is to filter `PATH` at shell startup. Add the following line to the end of your ~/.bashrc (or relevant shell init file):

```bash
export PATH=$(echo "$PATH" | tr ':' '\n' | grep -v ' ' | paste -sd:)
```

This will remove all paths with spaces from your `PATH` variable.

Restart the shell or source the edited file to apply the changes. This solution retains useful Windows paths such as `/c/Windows/System32/`, allowing tools like `cmd.exe` to remain accessible. If your simulator is installed in a directory without spaces, you can continue to run it via `vsim.exe` from within WSL.

Alternatively, you can disable Windows path import in WSL by adding the following lines to `/etc/wsl.conf`:

```conf
[interop]
appendWindowsPath = false
```

Shutdown and launch WSL again afterward. A disadvantage of this approach is that you will no longer be able to run Windows host executables (e.g., `cmd.exe`, `vsim.exe`) without specifying the full path.

> **Note:** Building Cheshire targets will generally work regardless of whether you apply any of the suggested `PATH` adjustments. However, modifying `PATH` may be necessary for building certain submodule targets, such as the `images` target in the `cva6-sdk` submodule.
