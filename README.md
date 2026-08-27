# Nordic News Radar – Terraform-Infrastruktur

Erster IaC-Entwurf für Phase 2 des IU-Projekts im Kurs Cloud Programming

## Architektur

Terraform stellt die vereinbarte AWS-Infrastruktur bereit:

- EventBridge Scheduler startet AWS Lambda einmal täglich.
- Lambda kann öffentliche Feed-Daten verarbeiten, Nova Micro über das systemdefinierte EU Inference Profile aufrufen und JSON nach S3 schreiben.
- Ein privater S3-Bucket enthält das Frontend, ein zweiter die Daten unter `data/`.
- Archivdateien unter `data/archive/` werden nach 14 Tagen gelöscht; `data/latest.json` bleibt bestehen.
- CloudFront liefert Frontend und Daten über HTTPS aus. `/data/*` wird an den Daten-Bucket geroutet.
- Origin Access Control hält beide S3-Buckets privat.
- CloudWatch Logs speichert Lambda-Protokolle für 14 Tage.
- AWS Budgets warnt bei 1 USD und 3 USD tatsächlichen Kosten sowie bei einer Prognose über dem 5-USD-Monatsbudget.

## Sicherheit und Reproduzierbarkeit

- Keine AWS-Zugangsschlüssel, Passwörter oder API-Keys im Terraform-Code.
- AWS-Anmeldedaten werden über die normale AWS Credential Chain bereitgestellt, z. B. AWS CLI/SSO oder Umgebungsvariablen.
- S3 Public Access Block ist für beide Buckets aktiviert.
- CloudFront greift signiert über Origin Access Control auf S3 zu.
- Lambda erhält nur die für S3, Bedrock und CloudWatch benötigten Rechte.
- Die Bedrock-Berechtigung wird auf das EU-Inferenzprofil und dessen tatsächlich hinterlegte Zielmodell-ARNs begrenzt.
- `terraform.tfvars` und Terraform-State-Dateien werden nicht versioniert.

## Voraussetzungen

1. Terraform >= 1.6
2. AWS-Konto mit ausreichenden Berechtigungen zum Anlegen der verwendeten Ressourcen
3. AWS-Zugang lokal eingerichtet, ohne Zugangsschlüssel im Terraform-Code zu speichern
4. Amazon Nova Micro muss im Konto nutzbar sein

## Bereitstellung

```bash
cp terraform.tfvars.example terraform.tfvars
# In terraform.tfvars die eigene Adresse für AWS-Budgets-Warnungen eintragen.

terraform init
terraform fmt -recursive
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

Danach zeigt `terraform output cloudfront_url` die Dashboard-Adresse.

Während der Entwicklung kann der tägliche Scheduler in `terraform.tfvars` mit `scheduler_enabled = false` deaktiviert werden.

## Aufräumen nach dem Kurs-Test

```bash
terraform destroy
```

`force_destroy_buckets = true` ist für dieses kurzlebige Kursprojekt voreingestellt, damit auch nichtleere Test-Buckets beim Aufräumen entfernt werden. Für ein produktives System wäre diese Einstellung normalerweise zu restriktiv bzw. zu riskant und sollte auf `false` gesetzt werden.
