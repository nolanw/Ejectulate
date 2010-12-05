Ejectulate
==========

The MacBook Air's eject key is kinda useless, as it doesn't have an optical drive. Even on machines with an optical drive, the eject key could be handier.

Ejectulate remaps the eject key to show a handy list of ejectable media. Disk images, network shares, external hard drives, and optical drives all appear in the list. And best of all, no yelling from Finder when unmounting one partition of many on the same drive.

It's also a useful tutorial for how to use a `CGEventTap` to observe or trap media key presses on Mac OS X. (Media keys are those that don't make it to your application: brightness up/down, volume up/down/off, and of course eject.) Have a look at `EJEjectKeyWatcher.m` for the event tap code.

