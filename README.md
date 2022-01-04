# Luup-Energenie-EG-PMS-LAN-Single

# Scope

This is a Luup plugin for HTTP control of the Energenie EG PMS (ENER019) LAN IP switches which creates a single device.

Luup (Lua-UPnP) is a software engine which incorporates Lua, a popular scripting language, and UPnP, the industry standard way to control devices. Luup is the basis of a number of home automation controllers e.g. Micasaverde Vera, Vera Home Control, OpenLuup.

# Compatibility

This plug-in has been tested with the following Energenie switches

* EG PMS LAN - > https://energenie4u.co.uk/res/pdfs/ENER019_User_Manual.pdf

# Features

It supports the following functions:

* Creation of a singke devices with on/off buttons for each switch channel
* Set each channel on or off from Vera (discrete power)
* Poll the device regularly to determine the actual status

# Imstallation / Usage

This installation assumes a default/factory set configuration is used, which makes the password '1'

1. Upload the two icon .png files to the appropriate storage location on your controller. For Vera that's `/www/cmh/skins/default/icons`
2. Upload the .xml and .json file in the repository to the appropriate storage location on your controller. For Vera that's via Apps/Develop Apps/Luup files/
3. Create the parent decice instance via the appropriate route. For Vera that's Apps/Develop Apps/Create Device/ and putting "D_Energenie.xml" into the Upnp Device Filename box and the IP address of your Energenie device.

# Limitations

While it has been tested, it has not been tested very much and may not support other related devices or those running different firmware.

# Buy me a coffee

If you choose to use/customise or just like this plug-in, feel free to say thanks with a coffee or two.. 
(God knows I drank enough working on this :-)) 

<a href="https://www.paypal.me/nodezero" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png" alt="Buy Me A Coffee" style="height: 41px !important;width: 174px !important;box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;-webkit-box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;" ></a>

# Screenshots

Once installed, and the IP address added, you should see the single device created.

![3B34698E-0C38-4AFB-A75F-E1A7EEE554D1](https://user-images.githubusercontent.com/4349292/148123179-5fac6bc0-ecab-4cf5-9b30-a4734890c11a.jpeg)


# License

Copyright © 2021 Chris Parker (nodecentral)

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/
