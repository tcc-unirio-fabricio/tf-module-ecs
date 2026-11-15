terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

variable "app_name" {
  description = "Application name used in resource names and tags."
  type        = string
  default     = null
  nullable    = true
}

variable "region" {
  description = "AWS region used by the consuming provider and ECS task logging."
  type        = string
}

variable "cpu" {
  description = "Fargate task CPU units."
  type        = number
  default     = null
  nullable    = true
}

variable "memory" {
  description = "Fargate task memory in MiB."
  type        = number
  default     = null
  nullable    = true
}

variable "port" {
  description = "Container and target group port; required by the application."
  type        = number
}

variable "protocol" {
  description = "Protocol used by the target group."
  type        = string
  default     = null
  nullable    = true
}

variable "container_image" {
  description = "Container image URI, including an optional tag. Defaults to nginx:latest."
  type        = string
  default     = null
  nullable    = true
}

variable "container_environment" {
  description = "Environment variables passed to the container."
  type        = map(string)
  default     = null
  nullable    = true
}

variable "desired_count" {
  description = "Number of ECS tasks to run."
  type        = number
  default     = null
  nullable    = true
}

variable "log_retention_days" {
  description = "CloudWatch log retention period in days."
  type        = number
  default     = null
  nullable    = true
}

variable "listener_rule_priority" {
  description = "Priority for the listener rule. Must be unique on the ALB listener."
  type        = number
  default     = null
  nullable    = true
}

variable "health_check_path" {
  description = "HTTP path used by the target group health check."
  type        = string
  default     = null
  nullable    = true
}

variable "enable_efs" {
  description = "Whether to create and mount an encrypted EFS file system."
  type        = bool
  default     = null
  nullable    = true
}

variable "efs_backup_policy" {
  description = "EFS backup policy status (ENABLED or DISABLED)."
  type        = string
  default     = null
  nullable    = true
}

variable "efs_container_path" {
  description = "Container path for the optional EFS volume."
  type        = string
  default     = null
  nullable    = true
}

variable "vpc_id" {
  description = "VPC ID where the service and optional EFS mount target will be created."
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs available to the ECS service. The first sorted subnet is used for the optional EFS mount target."
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) > 0
    error_message = "At least one subnet ID must be provided."
  }
}

variable "alb_dns_name" {
  description = "DNS name of the existing application load balancer."
  type        = string
}

variable "alb_listener_arn" {
  description = "ARN of the existing HTTP/HTTPS listener."
  type        = string
}

variable "alb_security_group_id" {
  description = "Security group ID attached to the existing ALB."
  type        = string
}

variable "ecs_cluster_arn" {
  description = "ARN of the existing ECS cluster."
  type        = string
}

variable "tags" {
  description = "Additional tags applied to created resources."
  type        = map(string)
  default     = null
  nullable    = true
}

locals {
  app_name               = var.app_name == null ? "ecs-app" : var.app_name
  cpu                    = var.cpu == null ? 256 : var.cpu
  memory                 = var.memory == null ? 512 : var.memory
  port                   = var.port
  protocol               = var.protocol == null ? "HTTP" : upper(var.protocol)
  container_image        = var.container_image == null ? "nginx:latest" : var.container_image
  container_environment  = var.container_environment == null ? {} : var.container_environment
  desired_count          = var.desired_count == null ? 1 : var.desired_count
  log_retention_days     = var.log_retention_days == null ? 7 : var.log_retention_days
  listener_rule_priority = var.listener_rule_priority == null ? 100 : var.listener_rule_priority
  health_check_path      = var.health_check_path == null ? "/" : var.health_check_path
  enable_efs             = var.enable_efs == null ? false : var.enable_efs
  efs_backup_policy      = var.efs_backup_policy == null ? "DISABLED" : upper(var.efs_backup_policy)
  efs_container_path     = var.efs_container_path == null ? "/app/data" : var.efs_container_path
  tags                   = var.tags == null ? {} : var.tags

  alb_dns_name          = var.alb_dns_name
  alb_listener_arn      = var.alb_listener_arn
  alb_security_group_id = var.alb_security_group_id
  vpc_id                = var.vpc_id
  subnet_ids            = var.subnet_ids
  ecs_cluster_arn       = var.ecs_cluster_arn
  efs_subnet_id         = sort(var.subnet_ids)[0]
  aws_region            = var.region
}
