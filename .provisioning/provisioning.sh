#!/bin/sh

# decrypt files
gpg --quiet --batch --yes --decrypt --passphrase="$PROVISIONING_CRYPT_PASSWORD" \
	--output draft-jskeum.mobileprovision JSKeum.mobileprovision.gpg

gpg --quiet --batch --yes --decrypt --passphrase=$CERTIFICATE_CRYPT_PASSWORD \
	--output draft-jskeum.p12 draft-certificate.p12.gpg

# set provisioning
mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles

echo "list profiles"
ls -/Library/MobileDevice/Provisioning\ profiles/
echo "move profiles"
cp draft-jskeum.mobileprovision ~/Library/MobileDevice/Provisioning\ Profiles/
echo "list profiles"
ls -/Library/MobileDevice/Provisioning\ profiles/

# make keychain
security create-keychain -p "" build.keychain
security import draft-jskeum.p12 -t agg \
	-k ~/Library/Keychains/build.keychain -P "$CERT_PASSWORD" - A

security list-keychains -s ~/Library/Keychains/build.keychain
security default-keychain -s ~/Library/Keychains/build.keychain
security unlock-keychain -p "" ~/Library/Keychains/build.keychain
security set-key-partition-list -S apple-tool: ,apple: -s \
	-k "" ~/Library/Keychains/build.keychain

