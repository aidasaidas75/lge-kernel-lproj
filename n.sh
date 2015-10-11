#!/bin/sh
git apply /home/android-build/3.4.0_3.4.108/0069-*.patch 2>&1 | sed -r 's/'$(echo -e "\033")'\[[0-9]{1,2}(;([0-9]{1,2})?)?[mK]//g' | tee /home/android-build/outputfile.txt
if grep -o 'patch does not apply' /home/android-build/outputfile.txt; then
git apply -R /home/android-build/3.4.0_3.4.108/0069-*.patch;
fi
rm /home/android-build/outputfile.txt
git apply /home/android-build/3.4.0_3.4.108/0070-*.patch 2>&1 | sed -r 's/'$(echo -e "\033")'\[[0-9]{1,2}(;([0-9]{1,2})?)?[mK]//g' | tee /home/android-build/outputfile.txt
if grep -o 'patch does not apply' /home/android-build/outputfile.txt; then
git apply -R /home/android-build/3.4.0_3.4.108/0070-*.patch;
fi
rm /home/android-build/outputfile.txt
