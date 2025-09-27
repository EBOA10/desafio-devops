variable "aws_region" {
  description = "Região da AWS onde a infraestrutura será criada."
  type        = string
  default     = "us-east-1"

  validation {
    # Garante que a região informada seja uma das duas opções válidas
    condition     = contains(["us-east-1", "sa-east-1"], var.aws_region)
    error_message = "A região da AWS precisa ser 'us-east-1' ou 'sa-east-1'."
  }
}

variable "desafio-devops" {
  description = "Nome do projeto. Usado para nomear e indetificar os recursos criados."
  type        = string
  default     = "php-modernization"

  validation {
    # Garante que o nome do projeto tenha entre 5 e 20 caracteres
    condition     = length(var.project_name) >= 5 && length(var.project_name) <= 20
    error_message = "O nome do projeto deve ter entre 5 e 20 caracteres."
  }
}
