files=$(ls *.sh)
files2=$(ls *.prop)
for i in $files $files2 "deviceconfig.txt"; do
	dos2unix $i
done
version=$(cat module.prop | grep version= | cut -d= -f2)
if [ -z $(echo version | grep beta) ]; then
	BETA_BUILD=0
else
	BETA_BUILD=1
	echo "Enabing beta flags"
fi
rm -rf *.zip
rm -rf out
sed -i -e "s/DEVICE_USES_VOLUME_KEY=0/DEVICE_USES_VOLUME_KEY=1/g" module.prop
if [ $BETA_BUILD -eq 1 ]; then
sed -i -e "s/BETA_BUILD=0/BETA_BUILD=1/g" module.prop
else
sed -i -e "s/BETA_BUILD=1/BETA_BUILD=0/g" module.prop
fi
sed -i -e "s/Pixelify\/master\/update-no-vk.json/Pixelify\/master\/update.json/g" module.prop
7z a Pixelify-v$version.zip $(ls | grep -v pixelify.sh | grep -v out | grep -v .zip | grep -v .md | grep -v recording.txt | grep -v .json | grep -v LICENSE | grep -v build.sh)
sed -i -e "s/DEVICE_USES_VOLUME_KEY=1/DEVICE_USES_VOLUME_KEY=0/g" module.prop
sed -i -e "s/Pixelify\/master\/update.json/Pixelify\/master\/update-no-vk.json/g" module.prop
7z a Pixelify-v$version-no_VK.zip $(ls | grep -v pixelify.sh | grep -v out | grep -v .zip | grep -v .md | grep -v recording.txt | grep -v .json | grep -v LICENSE | grep -v build.sh)
mkdir -p out
rm -rf out/*
mv Pixelify-v$version.zip out
mv Pixelify-v$version-no_VK.zip out
cp -f config.prop out/config.prop