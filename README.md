# aws-client-vpn-certificate-generation

# Purpose

[AWS Client VPN](https://docs.aws.amazon.com/vpn/latest/clientvpn-admin/what-is.html) is a service that allows you to privately access your AWS VPC from a local machine via a VPN connection. 

AWS Client VPN supports either certificate-based mutual authentication or Active Directory authentication. This project walks you through the steps needed to quickly generate certificates compatible with AWS Client VPN and upload them to AWS Certificate Manager. From there, you can follow the AWS documentation to begin using AWS Client VPN.

## Why?

This project was adapted from the [AWS documentation](https://docs.aws.amazon.com/vpn/latest/clientvpn-admin/authentication-authrization.html#mutual) because (at the time of this writing) the AWS examples for certificate generation specified an example domain that wasn't fully qualified which allowed the certs to be imported to Amazon Certificate Manager (ACM) but not usable by AWS Client VPN. 

The AWS docs have since been fixed on March 3 2019 [in this commit](https://github.com/awsdocs/aws-client-vpn-administrator-guide/commit/9e6faef841ab46c8d42a68922a70160abf134912).

Specifically, the old docs showed the line below, which would create a client certificate with a domain of "client1". This would be accepted by ACN but not usable:

```
# This is accepted by ACN but won't work with AWS Client VPN; "client1" needs to be a FQDN:
$ ./easyrsa build-client-full client1 nopass
```

The docs now show the line below, where the expectation is that you would preprend "client" (or "client1", "client2", etc.) do your domain name (e.g example.com) for a fully-qualified name such as client1.vpn.example.com. The idea is that your server cert would be similar, such as "server.vpn.example.com":

```
# This works, its a FQDN
$ ./easyrsa build-client-full client1.domain.tld nopass
```


## AWS Client VPN vs. AWS Site-to-Site VPN (formerly "VPN Gateway")

AWS Client VPN differs from [AWS Site-to-Site VPN](https://docs.aws.amazon.com/vpn/latest/s2svpn/VPC_VPN.html) (formerly known as VPN Gateway or "VGW") in the following ways:

1. Client VPN is encrypted over TLS while VGW is IPSEC.
2. Client VPN creates an encrypted tunnel to your VPC from any device that supports [OpenVPN](https://en.wikipedia.org/wiki/OpenVPN) (e.g. laptop, mobile device, etc.), whereas VGW creates a connection between a physical customer-managed VPN appliance on-premises and an AWS-managed gateway in your VPC.

There are other differences between Client VPN and VGW, as well. You should refer to each service's documentation for details.

## Use Cases

While AWS Site-to-site VPN is (typically) used for connecting on-premises networks to your AWS VPC, AWS Client VPN is instead used for connecting specific devices to your VPC. 

## Deployment

The **deploy.sh** script will use [EasyRSA](https://github.com/OpenVPN/easy-rsa) to generate a client certificate and server certificate and upload them to [AWS Certificate Manager](https://aws.amazon.com/certificate-manager/).  

1. Open **deploy.sh** and change the **DOMAIN** to be a domain of your choice. For test purposes, you do not need to own the domain. Note that the domain does need to be in a valid FQDN format (e.g. something.com or something.net). If not in that format, AWS Certificates Manager may accept the certificate upload but they will not be available for use with AWS Client VPN:

    ```sh
    # Deploy.sh
    DOMAIN=vpn.example.com
    ```

    As an example:
    
    ```sh
    # Deploy.sh
    DOMAIN=vpn.matwerber.info
    ```

2. Optionally, edit the region to match the region you will be working in:

    ```sh
    REGION=us-east-1
    ```

3. Run **deploy.sh**:

    ```sh
    $ ./deploy.sh
    ```

4. **SAVE** the files created locally. At a minimum, you will need the client files when later setting up your OpenVPN client.

5. Afterwards, you should be able to continue at [**Step 2: Create a Client VPN Endpoint** in the AWS Documentation](https://docs.aws.amazon.com/vpn/latest/clientvpn-admin/cvpn-getting-started.html#cvpn-getting-started-endpoint). 
