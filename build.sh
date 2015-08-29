#!/bin/bash

# Written by cybojenix <anthonydking@gmail.com>
# Edited by Aidas Lukošius - aidasaidas75 <aidaslukosius75@yahoo.com>
# credits to Rashed for the base of zip making
# credits to the internet for filling in else where

echo "this is an open source script, feel free to use and share it"

# Vars
export ARCH=arm
export SUBARCH=arm
export KBUILD_BUILD_USER=aidasaidas75
export KBUILD_BUILD_HOST=
kernel="LukoSius"
rel="R15"
daytime=$(date +%d"-"%m"-"%Y"_"%H"-"%M)
location=.

# Prepare output customization commands
red=$(tput setaf 1)             #  red
grn=$(tput setaf 2)             #  green
blu=$(tput setaf 4)             #  blue
cya=$(tput setaf 6)             #  cyan
txtbld=$(tput bold)             # Bold
bldred=${txtbld}$(tput setaf 1) #  red
bldgrn=${txtbld}$(tput setaf 2) #  green
bldblu=${txtbld}$(tput setaf 4) #  blue
bldcya=${txtbld}$(tput setaf 6) #  cyan
txtrst=$(tput sgr0)             # Reset


echo "${bldgrn}Pick variant...${txtrst}"
select choice in e610 e612
do
case "$choice" in
	"e610")
		export target="e610"
		export defconfig="cyanogenmod_m4_defconfig"
		break;;
	"e612")
		export target="e612"
		export defconfig="cyanogenmod_m4_nonfc_defconfig"
		break;;
esac
done

echo "${bldgrn}please specify a location, including the '/bin/arm-eabi-' at the end ${txtrst}"
read compiler

cd $location
export ARCH=arm
export CROSS_COMPILE=$compiler
if [ -z "$clean" ]; then
    read -p "${bldgrn}do make clean mrproper?(y/n)${txtrst}" clean
fi # [ -z "$clean" ]
case "$clean" in
    y|Y ) echo "${bldcya}cleaning...${txtrst}"; make clean mrproper;;
    n|N ) echo "${bldcya}continuing...${txtrst}";;
    * ) echo "${bldred}invalid option${txtrst}"; sleep 2 ; build.sh;;
esac

echo "${grn}now building the kernel${txtrst}"

START=$(date +%s)

make $defconfig

	# Check cpu's
	NR_CPUS=$(grep -c ^processor /proc/cpuinfo)

	if [ "$NR_CPUS" -le "2" ]; then
		NR_CPUS=4;
		echo "${bldblu}Building kernel with 4 CPU threads${txtrst}";
	else
		echo "${bldblu}Building kernel with $NR_CPUS CPU threads${txtrst}";
	fi;

make -j ${NR_CPUS}

## the zip creation
if [ -f arch/arm/boot/zImage ]; then

    rm -f zip-creator/kernel/zImage
    rm -rf zip-creator/system/

    # changed antdking "clean up mkdir commands" 04/02/13
    mkdir -p zip-creator/system/lib/modules

    cp arch/arm/boot/zImage zip-creator/kernel
    # changed antdking "now copy all created modules" 04/02/13
    # modules
    # (if you get issues with copying wireless drivers then it's your own fault for not cleaning)

    find . -name *.ko | xargs cp -a --target-directory=zip-creator/system/lib/modules/

    zipfile="$kernel"-kernel_"$target"-"$rel".zip
    cd zip-creator
    rm -f *.zip
    zip -r $zipfile * -x *kernel/.gitignore*

    echo "${bldblu}zip saved to zip-creator/$zipfile ${txtrst}"

else # [ -f arch/arm/boot/zImage ]
    echo "${bldred} the build failed so a zip won't be created ${txtrst}"
fi # [ -f arch/arm/boot/zImage ]

END=$(date +%s)
BUILDTIME=$((END - START))
B_MIN=$((BUILDTIME / 60))
B_SEC=$((BUILDTIME - E_MIN * 60))
echo -ne "\033[32mBuildtime: "
[ $B_MIN != 0 ] && echo -ne "$B_MIN min(s) "
echo -e "$B_SEC sec(s)\033[0m"

read -p "Press [Enter] key to exit..."
exit
