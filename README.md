# nvidia-optimus-kill
This is a simple Windows Powershell script intended to alleviate a bug in the Nvidia Optimus graphics card switching technology that prevents the laptop from switching the dGPU off even when it's no longer in use. This leads to unnecessary power drain and periodic stuttering as Optimus tries and fails to switch off the dGPU.

According to the Optimus spec, a process is assigned to either the integrated GPU or discrete GPU on launch, and it will remain there until it terminates. Normally, only processes requiring high graphics performance will get assigned to the dGPU, while all others will happily start on the iGPU. However, a lot of Optimus laptops have the HDMI output port hardwired to the dGPU. Depending on how Optimus is implemented on a particular model, this might mean that while an external monitor is plugged in and set as the main screen, ALL new processes launch on the dGPU and will remain there until they terminate. This includes a couple of Windows processes like DWM that automatically relaunch when an external monitor is detected.

Once the external monitor is unplugged, one would expect Optimus to switch the dGPU off to conserve battery power, but since there are now running processes tied to the dGPU, this fails. Not only does the dGPU keep draining battery power, but every time Optimus tries and fails to switch it off (every 10 seconds or so) it produces a "stutter" that can be really annoying.

This short script uses the nvidia-smi tool to list all processes currently running on the dGPU, and allows you stop them with the push of a single convenient keystroke. This frees the dGPU up and lets Optimus finally do its job. Not very elegant, but effective.

Needless to say, this might shut down some running apps and any unsaved changes will be lost, so make sure to take a look at the list of processes that will be stopped before going ahead.
