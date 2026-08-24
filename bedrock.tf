# Das EU-Inferenzprofil ist systemdefiniert und wird von AWS verwaltet.
# Terraform erstellt deshalb kein eigenes Bedrock-Modell, sondern liest das vorhandene Profil aus.
data "aws_bedrock_inference_profile" "nova_micro_eu" {
  inference_profile_id = var.bedrock_inference_profile_id
}
