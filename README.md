# aws-client-vpn-certificate-generation

# Purpose

[AWS Client VPN](https://docs.aws.amazon.com/vpn/latest/clientvpn-admin/what-is.html) is a service that allows you to privately access your AWS VPC from a local machine via a VPN connection. 

AWS Client VPN supports either certificate-based mutual authentication or Active Directory authentication. This project walks you through the steps needed to quickly generate certificates compatible with AWS Client VPN and upload them to AWS Certificate Manager. From there, you can follow the AWS documentation to begin using AWS Client VPN.

## Why?

This project was adapted from the [AWS documentation](https://docs.aws.amazon.com/vpn/latest/clientvpn-admin/authentication-authrization.html#mutual) because (at the time of this writing) the AWS examples for certificate generation had subtle errors that caused things to fail. I spent a lot of time trying to troubleshoot and wanted to share my learnings. Perhaps this is fixed now? As I write this README, it's been a couple of months since Client VPN's release.

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