#!/bin/bash
# Script pour accepter les licences Android SDK

echo "Création du répertoire de licences..."
sudo mkdir -p /usr/lib/android-sdk/licenses

echo "Acceptation des licences Android SDK..."
echo "24333f8a63b6825ea9c5514f83c2829b004d1fee" | sudo tee /usr/lib/android-sdk/licenses/android-sdk-license > /dev/null
echo "601085b94cd77f0b54ff86406957099ebe79c4d6" | sudo tee /usr/lib/android-sdk/licenses/android-sdk-preview-license > /dev/null
echo "84831b9409646a918e30573bab4c9c91346d8abd" | sudo tee /usr/lib/android-sdk/licenses/android-sdk-preview-license > /dev/null
echo "d975f751698a77b662f1254ddbeed3901e976f5a" | sudo tee /usr/lib/android-sdk/licenses/intel-android-extra-license > /dev/null
echo "8403addf88ab4874007e1c1e80a5e619eafcddfc" | sudo tee /usr/lib/android-sdk/licenses/android-googletv-license > /dev/null
echo "33b6a2b64607f4b7bff3a9d2f07e04da884611c" | sudo tee /usr/lib/android-sdk/licenses/google-gdk-license > /dev/null
echo "79120722343a6f314e0719f863036c702b0e6b2a" | sudo tee /usr/lib/android-sdk/licenses/mips-android-sysimage-license > /dev/null
echo "e9acab5b5fbb560a72cfaecce8946896ff6aab9d" | sudo tee /usr/lib/android-sdk/licenses/android-sdk-arm-dbt-license > /dev/null

echo "Licence NDK..."
echo "8403addf88ab4874007e1c1e80a5e619eafcddfc" | sudo tee /usr/lib/android-sdk/licenses/android-ndk-license > /dev/null

echo ""
echo "Vérification des licences acceptées:"
ls -la /usr/lib/android-sdk/licenses/

echo ""
echo "Licences acceptées! Vous pouvez maintenant construire l'APK avec:"
echo "  flutter build apk"

