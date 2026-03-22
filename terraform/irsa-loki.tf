locals {
  loki = {
    namespace            = "loki"
    service_account_name = "loki"
  }
}

module "irsa_loki" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "5.55.0"
  create_role                   = true
  role_name                     = "${local.cluster_name}-grafana-loki-role"
  provider_url                  = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.loki.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.loki.namespace}:${local.loki.service_account_name}"]
}


resource "aws_iam_policy" "loki" {
  name        = "${local.cluster_name}-grafana-loki-policy"
  description = "EKS Grafana Loki policy for cluster ${local.cluster_name}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowS3Access",
        Effect = "Allow",
        Action = [
          "s3:ListBucket",
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject"
        ],
        Resource = [
          aws_s3_bucket.loki.arn,
          "${aws_s3_bucket.loki.arn}/*"
        ]
      },
      {
        Sid    = "AllowKMSAccess",
        Effect = "Allow",
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ],
        Resource = aws_kms_key.kms.arn
      }
    ]
  })
}