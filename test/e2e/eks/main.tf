/*
 * Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 * SPDX-License-Identifier: MIT-0
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this
 * software and associated documentation files (the "Software"), to deal in the Software
 * without restriction, including without limitation the rights to use, copy, modify,
 * merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
 * PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

terraform {
  required_version = ">= 1.0.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.66.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.7.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.4.1"
    }
  }
}

terraform {
  backend "s3" {
    bucket = "terraform-ssp-github-actions-state"
    key    = "e2e/eks/terraform-main.tfstate"
    region = "us-west-2"
  }
}
# Importing VPC remote state config
data "terraform_remote_state" "vpc_s3_backend" {
  backend = "s3"
  config = {
    bucket = "terraform-ssp-github-actions-state"
    key    = "e2e/vpc/terraform-main.tfstate"
    region = "us-west-2"
  }
}

module "eks-cluster-with-import-vpc" {
  source = "../../../deploy/2-eks-cluster-with-import-vpc/eks"

  tenant      = "aws001"
  environment = "preprod"
  zone        = "test"

  vpc_id             = data.terraform_remote_state.vpc_s3_backend.outputs.vpc_id
  private_subnet_ids = data.terraform_remote_state.vpc_s3_backend.outputs.private_subnets
  public_subnet_ids  = data.terraform_remote_state.vpc_s3_backend.outputs.public_subnets
}
