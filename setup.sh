#!/bin/bash

# Adapted from https://docs.aws.amazon.com/vpn/latest/clientvpn-admin/authentication-authrization.html#mutual

# Must use FQDN when running the "easyrsa build-..."" commands; otherwise, the certs will import to AWS ACM but will not appear as usable
DOMAIN=vpn.example.com
SERVER_DOMAIN=server.$DOMAIN
CLIENT_DOMAIN=client.$DOMAIN

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

aws acm import-certificate --certificate file://$SERVER_DOMAIN.crt  --private-key file://$SERVER_DOMAIN.key  --certificate-chain file://ca.crt --region us-east-1
aws acm import-certificate --certificate file://$CLIENT_DOMAIN.crt --private-key file://$CLIENT_DOMAIN.key --certificate-chain file://ca.crt --region us-east-1