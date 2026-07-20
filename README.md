# Lists
This repository contains lists of various lists of scanned urls, backdoor files and other abused files. With this Lists you can scan your website for any malicious 
files. (Not realy intended but a nice side effect) Select lists to use as Honeypots to block access to your website from malicious users.

## Lists
- [keywords](./build/keywords.txt)
- [keywords-commands](./build/keywords-commands.txt)
- [ips](./build/ips.txt)
- [sql-admin](./build/sql-admin.txt)
- [cgi-bin-catch-all](./build/cgi-bin-catch-all.txt)
- [cgi-bin](./build/cgi-bin.txt)
- [wordpress-catch-all](./build/wordpress-catch-all.txt)
- [unrealisitic](./build/unrealisitic.txt)
- [common-abused-files](./build/common-abused-files.txt)
- [common-leaks](./build/common-leaks.txt)
- [common-files](./build/common-files.txt)
- [common-folders](./build/common-folders.txt)
- [common-impersonation-folders](./build/common-impersonation-folders.txt)
- [common-backdoors](./build/common-backdoors.txt)
- [.well-known](./build/.well-known.txt)
- [common-backdoors-well-known](./build/common-backdoors-well-known.txt)
- [unsure](./build/unsure.txt)
- [wordpress-plugins](./build/wordpress-plugins.txt)
- [wordpress-like](./build/wordpress-like.txt)
- [unsorted](./build/unsorted.txt)
- [placeholder](./build/placeholder.txt)

## Usage
## scan.sh
Used to scan a website for files in the lists. 
Helps you determine what lists you can use and maybe even finds some malicious files.

## build.sh
Is run as an Action in GitHub to build the lists. You can find the lists in the build directory.

## build_htaccess.sh 
Used to build a .htaccess file for the lists.
You can use this file to block access to your website from malicious users. 
Using -a flag will build the .htaccess file with all lists, otherwise you can specify the lists you want to use.

