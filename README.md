# Lists
This repository contains lists of various lists of scanned urls, backdoor files and other abused files. With this Lists you can scan your website for any malicious files. (Not realy intended but a nice side effect) Select lists to use as "Honeypots" to block access to your website from malicious users.

## Lists
Will be generated by the build.sh script in branch auto-build
[Auto-Build](https://github.com/smol-kitten/honeypot-urls/tree/auto-build)


# Usage
## scan.sh 
Used to scan a website for files in the lists. 
Helps you determine what lists you can use and maybe even finds some malicious files.

## build.sh
Is run as an Action in GitHub to build the lists. You can find the lists in the build directory.

## build_htaccess.sh 
Used to build a .htaccess file for the lists.
You can use this file to block access to your website from malicious users. 
Using -a flag will build the .htaccess file with all lists, otherwise you can specify the lists you want to use.

# Last Build
[![Build Lists](https://github.com/smol-kitten/honeypot-urls/actions/workflows/build.yml/badge.svg)](https://github.com/smol-kitten/honeypot-urls/actions/workflows/build.yml)