# quickgui_adw

A frontend for [quickemu](https://github.com/quickemu-project/quickemu) forked
from
[https://github.com/quickemu-project/quickgui](https://github.com/quickemu-project/quickgui).

Originally my intend was just to change it to use [Libadwaita
Flutter](https://pub.dev/packages/libadwaita), but ended up rewriting large
parts of it.

### Managing VMs

The "Manage running VMs" screen will list available Quickemu VMs in the current working directory.

VMs can be launched by clicking the "Play" (▶) button. Running VMs will have the "Play" and "Stop" buttons highlighted in green and red respectively, and pressing "Stop" (■) will kill the running VM.

When a VM is running, the host's ports mapped to SPICE and SSH on the guest will be displayed. If you close the SPICE display and wish to reconnect, you can click the "Connect display with SPICE" button. To open an SSH session, you can click the "Connect with SSH" button.

If the "Connect display with SPICE" button is disabled, the `spicy` client could not be found. Ensure it is installed, and in your PATH (it should have been installed with `quickemu`)

If the "Connect with SSH" button is disabled, an SSH server could not be detected on the guest. Most guest operating systems will not install an SSH server by default, so if it was not an option during install, you will need to install one yourself. It must be listening on port 22 (the default SSH port). Once a server is installed and running, it should be detected automatically.

"Connect with SSH" will use the terminal emulator symlinked to `x-terminal-emulator`. Several common terminal emulators are supported. If yours is not, please raise an issue on this repository.