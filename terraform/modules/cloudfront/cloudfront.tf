
# ACM Certificate

resource "aws_acm_certificate" "cert" {
  domain_name               = var.root_domain
  subject_alternative_names = ["*.${var.root_domain}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# ACM Certificate Validation

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  type            = each.value.type
  zone_id         = var.route53_zone_id
  records         = [each.value.record]
  ttl             = 60
}

resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

# Origin Access Control Configuration

resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "OAC for buckets"
  description                       = ""
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# S3 Bucket Configuration

resource "aws_s3_bucket" "subdomain" {
  bucket = var.subdomain
}

# Cloudfront distro for S3 bucket using OAC

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.subdomain.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
    origin_id                = aws_s3_bucket.subdomain.bucket
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  aliases             = [var.root_domain, var.subdomain]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.subdomain.bucket

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2018"
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

# Updating S3 Bucket Policy to restrict access to Cloudfront distribution

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.subdomain.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : {
      "Sid" : "AllowCloudFrontServicePrincipalReadOnly",
      "Effect" : "Allow",
      "Principal" : {
        "Service" : "cloudfront.amazonaws.com"
      },
      "Action" : "s3:GetObject",
      "Resource" : ["${aws_s3_bucket.subdomain.arn}/*"],
      "Condition" : {
        "StringEquals" : {
          "AWS:SourceArn" : ["${aws_cloudfront_distribution.s3_distribution.arn}"]
        }
      }
    }
  })
}

# Adding A records to Route53 inorder to direct Cloudfront distribution to domains

resource "aws_route53_record" "sub_a_record" {
  zone_id = var.route53_zone_id
  name    = var.subdomain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "root_a_record" {
  zone_id = var.route53_zone_id
  name    = var.root_domain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = true
  }
}