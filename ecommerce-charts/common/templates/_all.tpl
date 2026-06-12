{{- define "common.all" -}}
{{- include "common.serviceaccount" . }}
---
{{ include "common.deployment" . }}
---
{{ include "common.service" . }}
{{- $hpa := include "common.hpa" . -}}
{{- if $hpa }}
---
{{ $hpa }}
{{- end -}}
{{- $sm := include "common.servicemonitor" . -}}
{{- if $sm }}
---
{{ $sm }}
{{- end -}}
{{- $ing := include "common.ingress" . -}}
{{- if $ing }}
---
{{ $ing }}
{{- end -}}
{{- end -}}
