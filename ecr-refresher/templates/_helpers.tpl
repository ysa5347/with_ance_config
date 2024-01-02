{{/*
Expand the name of the chart.
*/}}
{{- define "ecr-refresher.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "ecr-refresher.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "ecr-refresher.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "ecr-refresher.labels" -}}
helm.sh/chart: {{ include "ecr-refresher.chart" . }}
{{ include "ecr-refresher.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "ecr-refresher.selectorLabels" -}}
app.kubernetes.io/name: {{ include "ecr-refresher.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of workloads
*/}}
{{- define "ecr-refresher.cronJobName" -}}
{{- printf "%s-%s" (include "ecr-refresher.fullname" .) "cronjob" }}
{{- end }}

{{- define "ecr-refresher.deploymentName" -}}
{{- printf "%s-%s" (include "ecr-refresher.fullname" .) "deployment" }}
{{- end }}

{{- define "ecr-refresher.serviceAccountName" -}}
{{- printf "%s-%s" (include "ecr-refresher.fullname" .) "serviceaccount" }}
{{- end }}

{{- define "ecr-refresher.secretName" -}}
{{- printf "%s-%s" (include "ecr-refresher.fullname" .) "env-secret" }}
{{- end }}

{{- define "ecr-refresher.configMapName" -}}
{{- printf "%s-%s" (include "ecr-refresher.fullname" .) "env-configmap" }}
{{- end }}

{{- define "ecr-refresher.roleName" -}}
{{- printf "%s-%s" (include "ecr-refresher.fullname" .) "update-role" }}
{{- end }}

{{- define "ecr-refresher.roleBindingName" -}}
{{- printf "%s-%s" (include "ecr-refresher.fullname" .) "rolebinder" }}
{{- end }}