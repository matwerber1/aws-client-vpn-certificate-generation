#!/bin/bash

set -e

# Adapted from https://docs.aws.amazon.com/vpn/latest/clientvpn-admin/authentication-authrization.html#mutual

# CONFIGURATION
#------------------------------------------------------------------------------------------------------------------
# Must use a FQDN for the values below, e.g. "example.com". Otherwise, the certs will 
# import to AWS ACM but will not appear as usable:
DOMAIN=example.com
SERVER_DOMAIN=server.$DOMAIN
CLIENT_DOMAIN=client.$DOMAIN
REGION=us-west-2

# Set this to whatever CLI version you are using, as the ACM import uses different commands depending on version. 
# Find your version using "aws --version":
CLI_VERSION=2

# If you have multiple CLI profiles, set the profile you want to use below. Otherwise, leave as empty string "":
PROFILE="--profile ctt-shared-services"


#------------------------------------------------------------------------------------------------------------------
# Current directory from which script is run...
CUR_DIR=$PWD

# Directory to which we later copy final certs; will be created if does not already exist
CERT_DIR=$CUR_DIR/client-vpn

# Create cert output directory if does not already exist
mkdir -p $CERT_DIR

git clone https://github.com/OpenVPN/easy-rsa.git

cd $CUR_DIR/easy-rsa/easyrsa3
./easyrsa init-pki
./easyrsa build-ca nopass
./easyrsa build-server-full $SERVER_DOMAIN nopass
./easyrsa build-client-full $CLIENT_DOMAIN nopass

cp $CUR_DIR/easy-rsa/easyrsa3/pki/ca.crt $CERT_DIR
cp $CUR_DIR/easy-rsa/easyrsa3/pki/issued/$SERVER_DOMAIN.crt $CERT_DIR
cp $CUR_DIR/easy-rsa/easyrsa3/pki/private/$SERVER_DOMAIN.key $CERT_DIR
cp $CUR_DIR/easy-rsa/easyrsa3/pki/issued/$CLIENT_DOMAIN.crt $CERT_DIR
cp $CUR_DIR/easy-rsa/easyrsa3/pki/private/$CLIENT_DOMAIN.key $CERT_DIR

cd $CERT_DIR

# Command to import certificate to AWS ACM varies slightly, depending on CLI version:
if [ $CLI_VERSION = 1 ]; then
  aws acm import-certificate \
    --certificate file://$SERVER_DOMAIN.crt  \
    --private-key file://$SERVER_DOMAIN.key  \
    --certificate-chain file://ca.crt \
    --region $REGION \
    $PROFILE

  aws acm import-certificate \
    --certificate file://$CLIENT_DOMAIN.crt \
    --private-key file://$CLIENT_DOMAIN.key \
    --certificate-chain file://ca.crt \
    --region $REGION \
    $PROFILE

else
  aws acm import-certificate \
    --certificate fileb://$SERVER_DOMAIN.crt  \
    --private-key fileb://$SERVER_DOMAIN.key  \
    --certificate-chain fileb://ca.crt \
    --region $REGION \
    $PROFILE

  aws acm import-certificate \
    --certificate fileb://$CLIENT_DOMAIN.crt \
    --private-key fileb://$CLIENT_DOMAIN.key \
    --certificate-chain fileb://ca.crt \
    --region $REGION \
    $PROFILE
fi