provider "aws" {
  region = var.aws_region
}

# Definições de Rede (VPC, Subnet, etc.)
resource "aws_vpc" "main" { cidr_block = "10.0.0.0/16"; tags = { Name = "${var.project_name}-vpc" } }
resource "aws_subnet" "public" { vpc_id = aws_vpc.main.id; cidr_block = "10.0.1.0/24"; map_public_ip_on_launch = true; tags = { Name = "${var.project_name}-subnet" } }
resource "aws_internet_gateway" "gw" { vpc_id = aws_vpc.main.id }
resource "aws_route_table" "main" { vpc_id = aws_vpc.main.id; route { cidr_block = "0.0.0.0/0"; gateway_id = aws_internet_gateway.gw.id } }
resource "aws_route_table_association" "a" { subnet_id = aws_subnet.public.id; route_table_id = aws_route_table.main.id }

# Grupo de Segurança para permitir tráfego HTTP
resource "aws_security_group" "ecs_service_sg" { name = "${var.project_name}-sg"; vpc_id = aws_vpc.main.id; ingress { from_port = 80; to_port = 80; protocol = "tcp"; cidr_blocks = ["0.0.0.0/0"] }; egress { from_port = 0; to_port = 0; protocol = "-1"; cidr_blocks = ["0.0.0.0/0"] } }

# Cluster ECS
resource "aws_ecs_cluster" "main" { name = "${var.project_name}-cluster" }

# IAM Role para execução da tarefa ECS
resource "aws_iam_role" "ecs_task_execution_role" { name = "${var.project_name}-ecs-execution-role"; assume_role_policy = jsonencode({ Version = "2012-10-17", Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "ecs-tasks.amazonaws.com" } }] }) }
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" { role = aws_iam_role.ecs_task_execution_role.name; policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy" }

# Definição da Tarefa ECS (o blueprint do contêiner)
resource "aws_ecs_task_definition" "app" { family = "${var.project_name}-task"; network_mode = "awsvpc"; requires_compatibilities = ["FARGATE"]; cpu = "256"; memory = "512"; execution_role_arn = aws_iam_role.ecs_task_execution_role.arn; container_definitions = jsonencode([{ name = "${var.project_name}-container", image = "eboa10/desafio-devops:latest", essential = true, portMappings = [{ containerPort = 80, hostPort = 80 }] }]) }

# Serviço ECS (responsável por manter o contêiner rodando)
resource "aws_ecs_service" "main" { name = "${var.project_name}-service"; cluster = aws_ecs_cluster.main.id; task_definition = aws_ecs_task_definition.app.arn; desired_count = 1; launch_type = "FARGATE"; network_configuration { subnets = [aws_subnet.public.id]; security_groups = [aws_security_group.ecs_service_sg.id]; assign_public_ip = true } }
