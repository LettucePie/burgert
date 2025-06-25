 #!/bin/bash

 VER=$(cat "../.git/refs/heads/master")
 echo $VER

butler push ./html lettucepie/burgert:html --userversion $VER
butler push ./linux lettucepie/burgert:linux --userversion $VER
butler push ./android lettucepie/burgert:android --userversion $VER
butler push ./windows lettucepie/burgert:windows --userversion $VER
butler push ./macos lettucepie/burgert:mac --userversion $VER
