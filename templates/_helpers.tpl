{{/*
Copyright Broadcom, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/* vim: set filetype=mustache: */}}

{{/*
Return the proper Microservice image name
*/}}
{{- define "ms.image" -}}
{{- include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global) -}}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "ms.imagePullSecrets" -}}
{{- include "common.images.pullSecrets" (dict "images" (list .Values.image) "global" .Values.global) -}}
{{- end -}}

{{/*
Create the name of the service account to use
 */}}
{{- define "ms.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "common.names.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "ms.postgresql.fullname" -}}
{{- include "common.names.dependency.fullname" (dict "chartName" "postgresql" "chartValues" .Values.postgresql "context" $) -}}
{{- end -}}

{{/*
Return the Database Hostname
*/}}
{{- define "ms.database.host" -}}
{{- if .Values.postgresql.enabled }}
    {{- if eq .Values.postgresql.architecture "replication" }}
        {{- printf "%s-primary" (include "ms.postgresql.fullname" .) | trunc 63 | trimSuffix "-" -}}
    {{- else -}}
        {{- printf "%s" (include "ms.postgresql.fullname" .) -}}
    {{- end -}}
{{- else -}}
    {{- printf "%s" .Values.externalDatabase.host -}}
{{- end -}}
{{- end -}}

{{/*
Return the Database Port
*/}}
{{- define "ms.database.port" -}}
{{- if .Values.postgresql.enabled }}
    {{- print .Values.postgresql.primary.service.ports.postgresql -}}
{{- else -}}
    {{- printf "%d" (.Values.externalDatabase.port | int ) -}}
{{- end -}}
{{- end -}}

{{/*
Return the Database database name
*/}}
{{- define "ms.database.name" -}}
{{- if .Values.postgresql.enabled }}
    {{- printf "%s" .Values.postgresql.auth.database -}}
{{- else -}}
    {{- printf "%s" .Values.externalDatabase.database -}}
{{- end -}}
{{- end -}}

{{/*
Return the Database User
*/}}
{{- define "ms.database.user" -}}
{{- if .Values.postgresql.enabled }}
    {{- printf "%s" .Values.postgresql.auth.username -}}
{{- else -}}
    {{- printf "%s" .Values.externalDatabase.user -}}
{{- end -}}
{{- end -}}

{{/*
Return the Database secret name
*/}}
{{- define "ms.database.secretName" -}}
{{- if .Values.postgresql.enabled }}
    {{- if .Values.postgresql.auth.existingSecret -}}
        {{- printf "%s" .Values.postgresql.auth.existingSecret -}}
    {{- else -}}
        {{- printf "%s" (include "ms.postgresql.fullname" .) -}}
    {{- end -}}
{{- else if .Values.externalDatabase.existingSecret -}}
    {{- include "common.tplvalues.render" (dict "value" .Values.externalDatabase.existingSecret "context" $) -}}
{{- else -}}
    {{- printf "%s-externaldb" (include "common.names.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Return the Database password secret key
*/}}
{{- define "ms.database.secretPasswordKey" -}}
{{- if .Values.postgresql.enabled -}}
    {{- print "password" -}}
{{- else -}}
    {{- if .Values.externalDatabase.existingSecret -}}
        {{- default "password" .Values.externalDatabase.existingSecretPasswordKey }}
    {{- else -}}
        {{- print "password" -}}
    {{- end -}}
{{- end -}}
{{- end -}}
{{/*
Return the Database password secret key
*/}}
{{- define "ms.database.secretPostgresPasswordKey" -}}
{{- if .Values.postgresql.enabled -}}
    {{- print "postgres-password" -}}
{{- else -}}
    {{- if .Values.externalDatabase.existingSecret -}}
        {{- default "postgres-password" .Values.externalDatabase.existingSecretPostgresPasswordKey }}
    {{- else -}}
        {{- print "postgres-password" -}}
    {{- end -}}
{{- end -}}
{{- end -}}
{{/*
Return whether Database uses password authentication or not
*/}}
{{- define "ms.database.auth.enabled" -}}
{{- if or (and .Values.postgresql.enabled .Values.postgresql.auth.enabled) (and (not .Values.postgresql.enabled) (or .Values.externalDatabase.password .Values.externalDatabase.existingSecret)) }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Return whether Database is enabled or not.
*/}}
{{- define "ms.database.enabled" -}}
{{- if or .Values.postgresql.enabled (and (not .Values.postgresql.enabled) (ne .Values.externalDatabase.host "localhost")) }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "ms.redis.fullname" -}}
{{- include "common.names.dependency.fullname" (dict "chartName" "redis" "chartValues" .Values.redis "context" $) -}}
{{- end -}}

{{/*
Return the Redis hostname
*/}}
{{- define "ms.redis.host" -}}
{{- if .Values.redis.enabled -}}
    {{- printf "%s-master" (include "ms.redis.fullname" .) -}}
{{- else -}}
    {{- print .Values.externalRedis.host -}}
{{- end -}}
{{- end -}}

{{/*
Return the Redis port
*/}}
{{- define "ms.redis.port" -}}
{{- if .Values.redis.enabled -}}
    {{- print .Values.redis.master.service.ports.redis -}}
{{- else -}}
    {{- print .Values.externalRedis.port  -}}
{{- end -}}
{{- end -}}

{{/*
Return the Redis secret name
*/}}
{{- define "ms.redis.secretName" -}}
{{- if .Values.redis.enabled }}
    {{- if .Values.redis.auth.existingSecret }}
        {{- printf "%s" .Values.redis.auth.existingSecret -}}
    {{- else -}}
        {{- printf "%s" (include "ms.redis.fullname" .) -}}
    {{- end -}}
{{- else if .Values.externalRedis.existingSecret }}
    {{- printf "%s" .Values.externalRedis.existingSecret -}}
{{- else -}}
    {{- printf "%s-redis" (include "common.names.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Return the Redis secret key
*/}}
{{- define "ms.redis.secretPasswordKey" -}}
{{- if .Values.redis.enabled -}}
    {{- print "redis-password" -}}
{{- else -}}
    {{- if .Values.externalRedis.existingSecret -}}
        {{- default "redis-password" .Values.externalRedis.existingSecretPasswordKey }}
    {{- else -}}
        {{- print "redis-password" -}}
    {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Return whether Redis uses password authentication or not
*/}}
{{- define "ms.redis.auth.enabled" -}}
{{- if or (and .Values.redis.enabled .Values.redis.auth.enabled) (and (not .Values.redis.enabled) (or .Values.externalRedis.password .Values.externalRedis.existingSecret)) }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Return whether Redis is enabled or not.
*/}}
{{- define "ms.redis.enabled" -}}
{{- if or .Values.redis.enabled (and (not .Values.redis.enabled) (ne .Values.externalRedis.host "localhost")) }}
    {{- true -}}
{{- end -}}
{{- end -}}
{{/*
Return the proper image name (for the init container volume-permissions image)
*/}}
{{- define "ms.initContainers.volumePermissions.image" -}}
{{- include "common.images.image" ( dict "imageRoot" .Values.defaultInitContainers.volumePermissions.image "global" .Values.global ) -}}
{{- end -}}

{{- define "ms.initContainers.volumePermissions" -}}
- name: volume-permissions
  image: "{{ include "ms.initContainers.volumePermissions.image" . }}"
  imagePullPolicy: {{ .Values.defaultInitContainers.volumePermissions.image.pullPolicy | quote }}
  command:
    - /bin/bash
  args:
    - -ec
    - |
      mkdir -p {{ .Values.persistence.mountPath }}
      {{- if eq ( toString ( .Values.defaultInitContainers.volumePermissions.containerSecurityContext.runAsUser )) "auto" }}
      find {{ .Values.persistence.mountPath }} -mindepth 0 -maxdepth 1 -not -name ".snapshot" -not -name "lost+found" | xargs -r chown -R $(id -u):$(id -G | cut -d " " -f2)
      {{- else }}
      find {{ .Values.persistence.mountPath }} -mindepth 0 -maxdepth 1 -not -name ".snapshot" -not -name "lost+found" | xargs -r chown -R {{ .Values.containerSecurityContext.runAsUser }}:{{ .Values.podSecurityContext.fsGroup }}
      {{- end }}
  {{- if .Values.defaultInitContainers.volumePermissions.containerSecurityContext.enabled }}
  securityContext: {{- include "common.compatibility.renderSecurityContext" (dict "secContext" .Values.defaultInitContainers.volumePermissions.containerSecurityContext "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.defaultInitContainers.volumePermissions.resources }}
  resources: {{- toYaml .Values.defaultInitContainers.volumePermissions.resources | nindent 4 }}
  {{- else if ne .Values.defaultInitContainers.volumePermissions.resourcesPreset "none" }}
  resources: {{- include "common.resources.preset" (dict "type" .Values.defaultInitContainers.volumePermissions.resourcesPreset) | nindent 4 }}
  {{- end }}
  volumeMounts:
    - name: data
      mountPath: {{ .Values.persistence.mountPath }}
      subPath: {{ .Values.persistence.subPath }}
{{- end -}}

{{/*
Return the proper image name (for the default init containers)
*/}}
{{- define "ms.initContainers.wait.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.defaultInitContainers.wait.image "global" .Values.global) }}
{{- end -}}

{{/*
Init container definition for waiting for Container to be ready
*/}}

{{- define "ms.initContainers.wait" -}}
- name: wait-for-it
  image: {{ include "ms.initContainers.wait.image" . }}
  imagePullPolicy: {{ .Values.defaultInitContainers.wait.image.pullPolicy }}
  {{- if .Values.defaultInitContainers.wait.containerSecurityContext.enabled }}
  securityContext: {{- include "common.compatibility.renderSecurityContext" (dict "secContext" .Values.defaultInitContainers.wait.containerSecurityContext "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.defaultInitContainers.wait.resources }}
  resources: {{- toYaml .Values.defaultInitContainers.wait.resources | nindent 4 }}
  {{- else if ne .Values.defaultInitContainers.wait.resourcesPreset "none" }}
  resources: {{- include "common.resources.preset" (dict "type" .Values.defaultInitContainers.wait.resourcesPreset) | nindent 4 }}
  {{- end }}
  command:
    - bash
    - -ec
    - |
      #!/bin/bash

      set -o errexit
      set -o nounset
      set -o pipefail

      {{ if .Values.defaultInitContainers.wait.config.services -}}
      wait-for-it \
        {{- range $service := .Values.defaultInitContainers.wait.config.services }}
        --service {{ $service.url }} \
        {{- end }}
        {{- if .Values.defaultInitContainers.wait.config.timeout }}
        --timeout {{ .Values.defaultInitContainers.wait.config.timeout }} \
        {{- end -}}
        {{- if .Values.defaultInitContainers.wait.config.parallel }}
        --parallel \
        {{- end -}}
        {{- if .Values.defaultInitContainers.wait.config.message }}
        -- echo "{{ .Values.defaultInitContainers.wait.config.message }}"
        {{- end -}}
      {{- else -}}
      echo "No services to wait for."
      {{ end }}

  env:
    - name: BITNAMI_DEBUG
      value: {{ ternary "true" "false" (or .Values.image.debug .Values.diagnosticMode.enabled) | quote }}
{{- end -}}

{{/*
Return the configmap with the Microservice configuration
*/}}
{{- define "ms.configmapName" -}}
{{- if .Values.existingConfigmap -}}
    {{- printf "%s" (tpl .Values.existingConfigmap $) -}}
{{- else -}}
    {{- printf "%s" (printf "%s-configuration" (include "common.names.fullname" .)) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Return true if a configmap object should be created for Microservice
*/}}
{{- define "ms.createConfigmap" -}}
{{- if and .Values.configuration (not .Values.existingConfigmap) }}
    {{- true -}}
{{- else -}}
{{- end -}}
{{- end -}}
