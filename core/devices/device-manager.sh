#!/data/data/com.termux/files/usr/bin/bash
set -u

case "${1:-status}" in

 status)
   echo "=== ANDROID DEVICES ==="
   adb devices
   ;;

 shell)
   adb shell
   ;;

 info)
   adb shell getprop ro.product.model 2>/dev/null || true
   adb shell getprop ro.build.version.release 2>/dev/null || true
   adb shell getprop ro.build.version.sdk 2>/dev/null || true
   ;;

 logcat)
   adb logcat -d -t 300
   ;;

 *)
   echo "status|shell|info|logcat"
   ;;
esac
