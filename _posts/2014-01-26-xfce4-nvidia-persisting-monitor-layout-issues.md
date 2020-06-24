---
layout: post
title: "XFCE4 & Nvidia – Persisting Monitor Layout Issues"
permalink: /xfce4-nvidia-persisting-monitor-layout-issues/
---

Looking around the internet, there are swathes of people who have had issues
with Nvidia not respecting their monitor layout choices after a reboot. After
nearly a day searching the net trying to figure out why my monitor layout was
reset to “clone mode” after a reboot, I found this to be the solution.

My issues came around after I installed a new monitor into my PC. As a result
of my new shiny monitor purchase, I had to change the layout of my monitors
(the monitor that used to be on the left, became the right-side monitor).
However, after doing so, the (now) right-side monitor insisted on cloning my
main monitor. I could go into the nvidia settings, but regardless of what I
did, the monitor reverted to cloning after restarting my PC. After digging
around in Xorg.conf and who knows how many other config files, I finally found
the problem not with the Nvidia drivers, or my X server, but with XFCE.

Simply, I did the following:

1. Open the XFCE Settings editor. You can access this from the Applications
   menu, in the setting section.
2. Go to the “displays” channel.
3. Change the “position” values of your monitors to reflect your monitor layout.

Alternatively, if you want (or need) to hack the configuration files directly. Do this:

1. Open the following XFCE settings folder:
   `/home/<your username>/.config/xfce4/xfconf/xfce-perchannel-xml/`
2. Find `displays.xml` (it should be the first file, if you sort them
   alphabetically).
   1. You should see a single XML root called “channel”, and then several
      `<properties>` tags. Each `<properties>` tag will itself have several
      `<properties>` tags within it (see below for an example)
   2. For me, each monitor was named after the connection it used into the PC.
      So my monitors were called “HDMI-0” and “DVI-D-0” because I have one HDMI
      monitor and one DVI monitor.
   3. In the properties for each monitor, you’ll see one called “Position”.
      This identifies where the monitor should exist in relation to the other.
      The Nvidia driver respects these position settings, and this is what is
      causing your layout to reset because the Nvidia driver will not change
      them, even if it DOES change your Xorg.conf file!
   4. Change the X and Y values of the monitor Position to match how your
      monitors are set up. If they are side by side, you should set the “X”
      value of the right-side monitor to be equal to the pixel width of the
      left-side monitor.
3. Once you’ve made the change, save the file and log out (or reboot). When you
   log back in, the monitor should again look normal.

This is the before and after of my displays.xml file:

**Before:**

```xml
<?xml version="1.0" encoding="UTF-8"?>

<channel name="displays" version="1.0">
 <property name="Default" type="empty">
    <property name="DVI-I-0" type="string" value="DVI-I-0">
      <property name="Active" type="bool" value="true"/>
      <property name="Resolution" type="string" value="1920x1080"/>
      <property name="RefreshRate" type="double" value="60.000000"/>
      <property name="Rotation" type="int" value="0"/>
      <property name="Reflection" type="string" value="0"/>
      <property name="Primary" type="bool" value="true"/>
      <property name="Position" type="empty">
        <property name="X" type="int" value="1920"/>
        <property name="Y" type="int" value="0"/>
      </property>
    </property>
    <property name="HDMI-0" type="string" value="HDMI-0">
      <property name="Active" type="bool" value="true"/>
      <property name="Resolution" type="string" value="1920x1080"/>
      <property name="RefreshRate" type="double" value="60.000000"/>
      <property name="Rotation" type="int" value="0"/>
      <property name="Reflection" type="string" value="0"/>
      <property name="Primary" type="bool" value="true"/>
      <property name="Position" type="empty">
        <property name="X" type="int" value="0"/>
        <property name="Y" type="int" value="0"/>
      </property>
    </property>
    <property name="DVI-D-0" type="string" value="Digital display">
      <property name="Active" type="bool" value="true"/>
      <property name="Resolution" type="string" value="1920x1080"/>
      <property name="RefreshRate" type="double" value="60.000000"/>
      <property name="Rotation" type="int" value="0"/>
      <property name="Reflection" type="string" value="0"/>
      <property name="Primary" type="bool" value="false"/>
      <property name="Position" type="empty">
        <property name="X" type="int" value="0"/>
        <property name="Y" type="int" value="0"/>
      </property>
    </property>
  </property>
</channel>
```

Notice above that I have three entries initially. This is because my HDMI
monitor was formally connected via a VGA cable.

**After:**

```xml
<?xml version="1.0" encoding="UTF-8"?>

<channel name="displays" version="1.0">
 <property name="Default" type="empty">
    <property name="HDMI-0" type="string" value="HDMI-0">
      <property name="Active" type="bool" value="true"/>
      <property name="Resolution" type="string" value="1920x1080"/>
      <property name="RefreshRate" type="double" value="60.000000"/>
      <property name="Rotation" type="int" value="0"/>
      <property name="Reflection" type="string" value="0"/>
      <property name="Primary" type="bool" value="true"/>
      <property name="Position" type="empty">
        <property name="X" type="int" value="1920"/>
        <property name="Y" type="int" value="0"/>
      </property>
    </property>
    <property name="DVI-D-0" type="string" value="Digital display">
      <property name="Active" type="bool" value="true"/>
      <property name="Resolution" type="string" value="1920x1080"/>
      <property name="RefreshRate" type="double" value="60.000000"/>
      <property name="Rotation" type="int" value="0"/>
      <property name="Reflection" type="string" value="0"/>
      <property name="Primary" type="bool" value="false"/>
      <property name="Position" type="empty">
        <property name="X" type="int" value="0"/>
        <property name="Y" type="int" value="0"/>
      </property>
    </property>
  </property>
</channel>
```

Notice that in the second one, the “DVI-I-0” monitor has been removed, and the
X value of monitor “DMI-0” has been changed so that it sits to the right of the
main monitor.

Do bear in mind that this isn’t the only fix for this. There are a whole
variety of reasons why Nvidia dual-monitor solutions might not work. This one
just seems to be the hardest to search for.
