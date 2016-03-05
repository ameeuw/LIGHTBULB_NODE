# ESP8266_SOCKET_NODE

This repository holds the code for a internet connected node. The hardware is based on very cheap in line relay switches called "SonOff" made by and available at ITEAD:
- [WiFi version](https://www.itead.cc/sonoff-wifi-wireless-switch.html)
- [WiFi & RF version](https://www.itead.cc/smart-home/im151116003.html)
- [Socket version](https://www.itead.cc/smart-home/slampher-wifi-wireless-light-holder.html)

The brain of this product is the Espressif ESP8266 chip, which is easy to program for. The collection of scripts makes use of a RestAPI module which allows for HTTP GET calls to control the relay of the device.

This is a very early version and will be improved over the next few weeks.

--------------

The source scripts are meant for use with the nodeMCU lua interpreting firmware. Get the latest firmware from their repository (https://github.com/nodemcu/nodemcu-firmware).
This code builds on top of revision 0.9.5 of the firmware and does not use floating point operations.