# sunmi_thermal_printer

A Flutter plugin for accessing the thermal printer on SunMi devices.

Tested on:
SunMi V1S

Probably works on other Sunmi devices equipped with SEIKO thermal printer.

## Getting Started

Add this plugin under `dependencies` to pubspec.yaml:
```` yaml
dependencies:
  sunmi_thermal_printer:
    git:
      url: git://github.com/brian-quah/sunmi_thermal_printer.git
      ref: master
````

Required permissions in AndroidManifest.xml:
``` xml
<uses-permission android:name="android.permission.BLUETOOTH" />
```
Needed to set up a virtual Bluetooth connection to communicate with the printer on the device.

In android/app/build.gradle:
Make sure `minSdkVersion` is set to 19 or above
Add to your dependencies:
``` groovy
implementation group: 'com.google.zxing', name: 'core', version: '3.4.0'
```