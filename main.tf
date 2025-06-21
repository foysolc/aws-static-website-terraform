resource "aws_s3_bucket" "website_bucket" {
  bucket = var.domain_name 

  tags = {
    Name        = "${var.domain_name}-website-bucket"
    Environment = "Dev"
    Project     = "FoysolCloud"
  }
}

resource "aws_s3_bucket_public_access_block" "website_bucket_public_access_block" {
  bucket = aws_s3_bucket.website_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

}
  
  resource "aws_s3_bucket_website_configuration" "website_config" {
  bucket = aws_s3_bucket.website_bucket.id 

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_cloudfront_origin_access_identity" "s3_oai" {
  comment = "OAI for ${var.domain_name} static website access via CloudFront"
}

resource "aws_s3_bucket_policy" "website_bucket_policy" {
  bucket = aws_s3_bucket.website_bucket.id 
  policy = jsonencode({ 
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.s3_oai.iam_arn
        }
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.website_bucket.arn}/*"
      },
    ]
  })
}

resource "aws_acm_certificate" "website_cert" {
  provider          = aws.us_east_1 
  domain_name       = var.domain_name 
  validation_method = "DNS"
  subject_alternative_names = [     
    "${var.subdomain_name}.${var.domain_name}",
    "*.${var.domain_name}"
  ]

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.domain_name}-ssl-certificate"
    Project = "FoysolCloud"
  }
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.website_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = aws_route53_zone.primary.zone_id 
  name    = each.value.name                 
  type    = each.value.type                 
  ttl     = 60                              
  records = [each.value.record]             
}

resource "aws_acm_certificate_validation" "cert_validation" {
  provider        = aws.us_east_1 
  certificate_arn = aws_acm_certificate.website_cert.arn 
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

resource "aws_route53_zone" "primary" {
  name = var.domain_name 

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.domain_name}-hosted-zone"
    Project = "FoysolCloud"
  }
}

resource "aws_route53_record" "www_alias" {
  zone_id = aws_route53_zone.primary.zone_id         
  name    = "${var.subdomain_name}.${var.domain_name}" 
  type    = "A"                                      

  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name 
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id 
    evaluate_target_health = false 
  }
}

resource "aws_route53_record" "root_alias" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = var.domain_name 
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_cloudfront_distribution" "s3_distribution" {

  origin {
    domain_name = aws_s3_bucket.website_bucket.bucket_regional_domain_name 
    origin_id   = "S3-${aws_s3_bucket.website_bucket.id}"                 

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.s3_oai.cloudfront_access_identity_path
    }
  }

  enabled             = true                  
  is_ipv6_enabled     = true                  
  comment             = "CloudFront distribution for ${var.domain_name}" 
  default_root_object = "index.html"          

  aliases = [
    var.domain_name,                       
    "${var.subdomain_name}.${var.domain_name}" 
  ]

  default_cache_behavior {
    target_origin_id = "S3-${aws_s3_bucket.website_bucket.id}" 

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

   
    forwarded_values {
      query_string = false
      headers      = ["Origin"] 
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0      
    default_ttl            = 3600   
    max_ttl                = 86400  
  }

  restrictions {
    geo_restriction {
      restriction_type = "none" 
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn            = aws_acm_certificate_validation.cert_validation.certificate_arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
  }

  tags = {
    Name = "${var.domain_name}-cloudfront-distribution"
    Project = "FoysolCloud"
  }
}