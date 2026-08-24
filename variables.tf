variable "aws_region" {
  description = "AWS-Quellregion der Anwendung. Für das Projekt ist Frankfurt vorgesehen."
  type        = string
  default     = "eu-central-1"
}

variable "project_slug" {
  description = "Kurzer, S3-kompatibler Projektname für Ressourcennamen."
  type        = string
  default     = "nordic-news-radar"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_slug)) && length(var.project_slug) <= 24
    error_message = "project_slug darf nur Kleinbuchstaben, Ziffern und Bindestriche enthalten und höchstens 24 Zeichen lang sein."
  }
}

variable "budget_email" {
  description = "E-Mail-Adresse für AWS-Budgets-Warnungen. Nicht im Repository fest eintragen; über terraform.tfvars setzen."
  type        = string
  sensitive   = true

  validation {
    condition     = can(regex("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$", var.budget_email))
    error_message = "Bitte eine gültige E-Mail-Adresse für die Budgetwarnungen angeben."
  }
}

variable "monthly_budget_usd" {
  description = "Monatliche Budgetobergrenze in USD. AWS Budgets ist eine Warnfunktion, keine harte Ausgabensperre."
  type        = number
  default     = 5
}

variable "schedule_expression" {
  description = "Täglicher EventBridge-Scheduler-Ausdruck. Standard: 07:00 Uhr in der konfigurierten Zeitzone."
  type        = string
  default     = "cron(0 7 * * ? *)"
}

variable "schedule_timezone" {
  description = "IANA-Zeitzone für den täglichen Scheduler."
  type        = string
  default     = "Europe/Berlin"
}

variable "scheduler_enabled" {
  description = "Aktiviert den täglichen Lauf. Kann während der Entwicklung vorübergehend auf false gesetzt werden."
  type        = bool
  default     = true
}

variable "archive_retention_days" {
  description = "Aufbewahrungsdauer der datierten Tagesausgaben im Daten-Bucket."
  type        = number
  default     = 14
}

variable "bedrock_inference_profile_id" {
  description = "Systemdefiniertes EU-Inferenzprofil für Amazon Nova Micro."
  type        = string
  default     = "eu.amazon.nova-micro-v1:0"
}

variable "force_destroy_buckets" {
  description = "Erlaubt terraform destroy, nichtleere Kurs-Buckets mitzulöschen. Für produktive Systeme normalerweise false."
  type        = bool
  default     = true
}
