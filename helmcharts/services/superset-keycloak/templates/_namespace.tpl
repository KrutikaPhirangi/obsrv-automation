# .Values.namespace will get overridden by .Values.global.namespace.chart-name
{{- define "base.namespace" -}}
  {{- $chartName := .Chart.Name }}
  {{- $namespace := default .Release.Namespace .Values.namespace }}
  {{- $namespace | trunc 63 | trimSuffix "-" }}
{{- end }}

