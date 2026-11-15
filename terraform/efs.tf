data "aws_subnet" "ecs" {
  count = local.enable_efs ? 1 : 0
  id    = local.efs_subnet_id
}

resource "aws_efs_file_system" "app" {
  count                  = local.enable_efs ? 1 : 0
  creation_token         = "${local.app_name}-efs"
  availability_zone_name = data.aws_subnet.ecs[0].availability_zone
  encrypted              = true

  tags = merge(local.tags, {
    Name = "${local.app_name}-efs"
  })
}

resource "aws_efs_backup_policy" "app" {
  count          = local.enable_efs ? 1 : 0
  file_system_id = aws_efs_file_system.app[0].id

  backup_policy {
    status = local.efs_backup_policy
  }
}

resource "aws_efs_access_point" "app" {
  count          = local.enable_efs ? 1 : 0
  file_system_id = aws_efs_file_system.app[0].id

  posix_user {
    uid = 1000
    gid = 1000
  }

  root_directory {
    path = "/app-data"

    creation_info {
      owner_uid   = 1000
      owner_gid   = 1000
      permissions = "0750"
    }
  }

  tags = merge(local.tags, {
    Name = "${local.app_name}-efs-access-point"
  })
}

resource "aws_efs_mount_target" "app" {
  count           = local.enable_efs ? 1 : 0
  file_system_id  = aws_efs_file_system.app[0].id
  subnet_id       = local.efs_subnet_id
  security_groups = [aws_security_group.efs[0].id]
}

output "efs_file_system_id" {
  description = "ID of the optional EFS file system."
  value       = try(aws_efs_file_system.app[0].id, null)
}

output "efs_access_point_id" {
  description = "ID of the optional EFS access point."
  value       = try(aws_efs_access_point.app[0].id, null)
}
