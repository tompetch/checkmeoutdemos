# checkmeoutdemo

https://checkmeout-demo.com/

**Background:**

We have been asked to create a website for a modern company that has recently migrated
their entire infrastructure to AWS. We need to demonstrate a basic website with some
text and an image, hosted and managed using modern standards and practices in AWS.
We can create your own application, or use open source or community software. The proof
of concept is to demonstrate hosting, managing, and scaling an enterprise-ready system.
This is not about website content or UI.

**Requirements:**

* Deliver the tooling to set up an application which displays a web page with text and
an image in AWS. (AWS free-tier is fine)
* Provide and document a mechanism for scaling the service and delivering the
content to a larger audience.
* Source code should be provided via a publicly accessible Github repository.
* Provide basic documentation to run the application along with any other
documentation you think is appropriate.
* Be prepared to explain your choices.

**Extra Mile Bonus (not a requirement)**

In addition to the above, time permitting, consider the following suggestions for taking your
implementation a step further.
* Monitoring/Alerting
* Security
* Automation
* Network diagrams

**Basic Design (v1):**

We are going to keep this POC very simple and stick with 3 main services. S3 for storage, CloudFront for content distribution and Route53 for hosting/dns. We will also use Certificate Manager for the ssl cert required for the web frontend.

![This is an image](/v1/docs/infra_v1.PNG)

This is a simple cost effective solution that meets all the functional requirements.

**DevOps:**

In this instance we will use github actions for our ci/cd pipelines, with terraform orchestrating our infrastructure. Some manual intervention is required with Route53 for purchasing the domain and configuring dns.

![This is an image](/v1/docs/cicd.PNG)

**Github actions pipelines:**

In the github/workflows folder there are two pipeline configurations, one for deploying the terraform, the other for uploading the website content to s3. The primary pipeline is trigged by a push to main and the second is on completion of primary.

**Security**

We are using an ssl certificate on the web front end and have also enabled encryption on the s3 buckets. Public access is technically allowed but we want to further restrict access to content by using an origin access identity and an updated bucket policy.

**Further Design (v2):**

Sadly we ran out of time to make further improvements to the POC. We do have a number of improvements and enhancements ready for version 2.

![This is an image](/v1/docs/infra_v2.PNG)

* Data input

As the website advances there will be a requirement for customers to enter data via forms. In this instance we want to use a combination of api gateway, lambda and dynamodb to process any customer requests.

* CMS

There will be a requirement to modify the site so a simple cms system along with strong RBAC controls will be important.

* Monitoring and logging

Aside from the usual networking related health checks available, we would like to visualise the CloudFront access logs.

* Security

Adding a waf to the CloudFront front end will enhance the security position.







