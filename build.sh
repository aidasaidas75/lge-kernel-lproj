#!/bin/bash

# Written by cybojenix <anthonydking@gmail.com>
# credits to Rashed for the base of zip making
# credits to the internet for filling in else where

echo "this is an open source script, feel free to use and share it"

# Colorize and add text parameters
grn=$(tput setaf 2)             #  Green
txtbld=$(tput bold)             # Bold
bldgrn=${txtbld}$(tput setaf 2) #  green
bldblu=${txtbld}$(tput setaf 4) #  blue
txtrst=$(tput sgr0)             # Reset

daytime=$(date +%d"-"%m"-"%Y"_"%H"-"%M)

location=.
vendor=lge
version=3.4.104

if [ -z $target ]; then
    echo "${bldgrn}choose your target device${txtrst}"
    echo "${bldblu}1) l7 p705${txtrst}"
    echo "${bldblu}2) l5 e610${txtrst}"
    echo "${bldblu}3) l5 e612${txtrst}"
    echo "${bldblu}4) l7 p700${txtrst}"
    read -p "1/2/3: " choice
    case "$choice" in
        1 ) export target=p705 ; export defconfig=cyanogenmod_u0_nonfc_defconfig;;
        2 ) export target=e610 ; export defconfig=cyanogenmod_m4_defconfig;;
        3 ) export target=e612 ; export defconfig=cyanogenmod_m4_nonfc_defconfig;;
        4 ) export target=p700 ; export defconfig=cyanogenmod_u0_defconfig;;
        * ) echo "${bldgrn}invalid choice${txtrst}"; sleep 2 ; $0;;
    esac
fi # [ -z $target ]

if [ -z $compiler ]; then
    if [ -f ../arm-eabi-4.6/bin/arm-eabi-* ]; then
        export compiler=../arm-eabi-4.6/bin/arm-eabi-
    elif [ -f arm-eabi-4.6/bin/arm-eabi-* ]; then # [ -f ../arm-eabi-4.6/bin/arm-eabi-* ]
        export compiler=arm-eabi-4.6/bin/arm-eabi-
    else # [ -f arm-eabi-4.6/bin/arm-eabi-* ]
        echo "${bldgrn}please specify a location, including the '/bin/arm-eabi-' at the end ${txtrst}"
        read compiler
    fi # [ -z $compiler ]
fi # [ -f ../arm-eabi-4.6/bin/arm-eabi-* ]

cd $location
export ARCH=arm
export CROSS_COMPILE=$compiler
if [ -z "$clean" ]; then
    read -p "${bldgrn}do make clean mrproper?(y/n)${txtrst}" clean
fi # [ -z "$clean" ]
case "$clean" in
    y|Y ) echo "${bldblu}cleaning...${txtrst}"; make clean mrproper;;
    n|N ) echo "${bldblu}continuing...${txtrst}";;
    * ) echo "${bldgrn}invalid option${txtrst}"; sleep 2 ; build.sh;;
esac

echo "${bldgrn}now building the kernel${txtrst}"

START=$(date +%s)

make $defconfig

	# Check cpu's
	NR_CPUS=$(grep -c ^processor /proc/cpuinfo)

	if [ "$NR_CPUS" -le "2" ]; then
		NR_CPUS=4;
		echo "Building kernel with 4 CPU threads";
	else
		echo "Building kernel with $NR_CPUS CPU threads";
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

    zipfile="$vendor-$target-v$version-$daytime.zip"
    cd zip-creator
    rm -f *.zip
    zip -r $zipfile * -x *kernel/.gitignore*

    echo "${bldgrn}zip saved to zip-creator/$zipfile ${txtrst}"

else # [ -f arch/arm/boot/zImage ]
    echo "${bldgrn} the build failed so a zip won't be created ${txtrst}"
fi # [ -f arch/arm/boot/zImage ]

END=$(date +%s)
BUILDTIME=$((END - START))
B_MIN=$((BUILDTIME / 60))
B_SEC=$((BUILDTIME - E_MIN * 60))
echo -ne "\033[32mBuildtime: "
[ $B_MIN != 0 ] && echo -ne "$B_MIN min(s) "
echo -e "$B_SEC sec(s)\033[0m"
