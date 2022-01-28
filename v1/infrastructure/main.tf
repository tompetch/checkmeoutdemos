terraform {
  backend "s3" {
    # Bucket name
    bucket         = "checkmeoutdemoterraformstate"
    key            = "global/s3/terraform.tfstate"
    region         = "eu-west-1"
    # DynamoDB table name
    dynamodb_table = "checkmeoutdemoterraformstatelock"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "website_bucket" {
  bucket = var.bucketname
  acl    = "public-read"
    
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "AES256"
      }
    }
  }
  versioning {
    enabled = true
  }

    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::${var.bucketname}/*"
            ]
        }
    ]
}
EOF

  website {
    index_document = "index.html"
    error_document = "error.html"

    routing_rules = <<EOF
[{
    "Condition": {
        "KeyPrefixEquals": "docs/"
    },
    "Redirect": {
        "ReplaceKeyPrefixWith": "documents/"
    }
}]
EOF
  }
}

resource "aws_acm_certificate" "certificate" {
  domain_name       = "*.${var.domain_name}"
  validation_method = "EMAIL"

  subject_alternative_names = ["${var.domain_name}"]
}

resource "aws_cloudfront_distribution" "website_distribution" {
  origin {
    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }

    domain_name = "${aws_s3_bucket.website_bucket.website_endpoint}"
    origin_id   = "${var.domain_name}"
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]

    target_origin_id       = "${var.domain_name}"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }
  aliases = ["${var.domain_name}"]

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn =  "${aws_acm_certificate.certificate.id}"
    ssl_support_method  = "sni-only"
  }
}

resource "aws_route53_zone" "zone" {
  name = "${var.domain_name}"
}

resource "aws_route53_record" "route53_record" {
  zone_id = "${aws_route53_zone.zone.zone_id}"
  name    = "${var.domain_name}"
  type    = "A"

  alias {
    name                   = "${aws_cloudfront_distribution.website_distribution.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.website_distribution.hosted_zone_id}"
    evaluate_target_health = false
  }
}

