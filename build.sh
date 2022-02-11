files=$(ls *.sh)
files2=$(ls *.prop)
for i in $files $files2 "deviceconfig.txt"; do
	dos2unix $i
done
version=$(cat module.prop | grep version= | cut -d= -f2)
rm -rf *.zip
rm -rf out
sed -i -e "s/DEVICE_USES_VOLUME_KEY=0/DEVICE_USES_VOLUME_KEY=1/g" module.prop
7z a Pixelify-v$version.zip *
sed -i -e "s/DEVICE_USES_VOLUME_KEY=1/DEVICE_USES_VOLUME_KEY=0/g" module.prop
7z a Pixelify-v$version-no_VK.zip $(ls | grep -v *.zip)
mkdir -p out
rm -rf out/*
mv Pixelify-v$version.zip out
mv Pixelify-v$version-no_VK.zip out
cp -f no-VK.prop out/no-VK.prop
