# Easy Certificate Installation

## What is it?

This small bash script is used to install a certificate in a JVM `cacerts` file, from a URL.

In order to do this, it needs the URL to get the certificate from, and it will attempt to 
find installed `cacerts` file. If it doesn't, the script will prompt for the full path to it.

## Usage

$ ./easy-cert-install.sh HOST PORT ALIAS

## Requirements

This script requires the followind installed on the system it runs:

1. Java properly installed (of course)
2. OpenSSL

