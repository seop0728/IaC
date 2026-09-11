variable "aws_region" {
  description = "AWS 리전"
  type        = string
  default     = "ap-northeast-2"
}

variable "project_name" {
  description = "프로젝트 이름 (리소스 이름 접두사에 사용)"
  type        = string
  default     = "myproject"
}

variable "project_environment" {
  description = "환경 이름 (dev/stage/prod 등)"
  type        = string
  default     = "development"
}

variable "instance_type" {
  description = "EC2 인스턴스 타입"
  type        = string
  default     = "t3.micro"
}

variable "ami_image" {
  description = "리전 -> Ubuntu 24.04 AMI ID"
  type        = map(string)
  default = {
    ap-northeast-2 = "ami-0e4ab31f1847c850c"
  }
}
