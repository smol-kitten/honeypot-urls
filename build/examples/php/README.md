This example is a prepend file to check if a path is in a list.
Ideally you prepend this only in your 404 page, to reduce load and prevent false positives.

# prepend.php
## Usage
- set lists to load in prepend.php
- set path to list file in prepend.php
- update page where you want to check for paths in list ( ideally 404 page )
- - require_once('path/prepend.php');