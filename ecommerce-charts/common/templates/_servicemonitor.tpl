{{- define "common.servicemonitor" -}}
{{- if .Values.metrics.enabled -}}
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: {{ include "common.fullname" . }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
    {{- with .Values.metrics.release }}
    release: {{ . | quote }}
    {{- end }}
spec:
  selector:
    matchLabels: {{- include "common.selectorLabels" . | nindent 6 }}
  endpoints:
    - port: {{ .Values.metrics.port | quote }}
      path: {{ .Values.metrics.path }}
      interval: {{ .Values.metrics.interval }}
      scrapeTimeout: {{ .Values.metrics.scrapeTimeout }}
{{- end -}}
{{- end -}}
