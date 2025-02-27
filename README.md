<!--- app-name: Microservice -->

# LaraGIS package for Microservice

## TL;DR

```console
helm install my-release oci://registry-1.docker.io/laragis/ms
```

## Introduction

This chart bootstraps a [Microservice](https://github.com/laragis/containers/tree/main/laragis/ms)
deployment on
a [Kubernetes](https://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.23+
- Helm 3.8.0+
- PV provisioner support in the underlying infrastructure
- ReadWriteMany volumes for deployment scaling

## Installing the Chart

To install the chart with the release name `my-release`:

```console
helm install my-release oci://REGISTRY_NAME/REPOSITORY_NAME/ms
```

> Note: You need to substitute the placeholders `REGISTRY_NAME` and `REPOSITORY_NAME` with a reference to your Helm
> chart registry and repository. For example, in the case of LaraGIS, you need to
> use `REGISTRY_NAME=registry-1.docker.io`
> and `REPOSITORY_NAME=laragis`.

The command deploys Microservice on the Kubernetes cluster in the default configuration.
The [Parameters](#parameters) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Configuration and installation details

### Resource requests and limits

LaraGIS charts allow setting resource requests and limits for all containers inside the chart
deployment. These are
inside the `resources` value (check parameter table). Setting requests is essential for production workloads and these
should be adapted to your specific use case.

To make this process easier, the chart contains the `resourcesPreset` values, which automatically sets the `resources`
section according to different presets. Check these presets
in [the bitnami/common chart](https://github.com/bitnami/charts/blob/main/bitnami/common/templates/_resources.tpl#L15).
However, in production workloads using `resourcePreset` is discouraged as it may not fully adapt to your specific needs.
Find more information on container resource management in
the [official Kubernetes documentation](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/).

### [Rolling VS Immutable tags](https://techdocs.broadcom.com/us/en/vmware-tanzu/application-catalog/tanzu-application-catalog/services/tac-doc/apps-tutorials-understand-rolling-tags-containers-index.html)

It is strongly recommended to use immutable tags in a production environment. This ensures your deployment does not
change automatically if the same tag is updated with a different image.

LaraGIS will release a new chart updating its containers if a new version of the main container,
significant changes, or
critical vulnerabilities exist.

### Known limitations

### External database support

You may want to have Microservice connect to an external database rather than installing one inside
your cluster. Typical reasons for this are to use a managed database service, or to share a common database server for
all your applications. To achieve this, the chart allows you to specify credentials for an external database with
the [`externalDatabase` parameter](#database-parameters). You should also disable the MariaDB installation with
the `ms.enabled` option. Here is an example:

```console
postgresql.enabled=false
externalDatabase.host=myexternalhost
externalDatabase.user=myuser
externalDatabase.password=mypassword
externalDatabase.database=mydatabase
externalDatabase.port=3306
```

If the database already contains data from a previous Microservice installation, set
the `msSkipInstall` parameter to `true`. This parameter forces the container to skip the Microservice installation wizard. Otherwise, the container will assume it is a fresh installation and
execute the installation wizard, potentially modifying or resetting the data in the existing database.

[Refer to the container documentation for more information](https://github.com/bitnami/containers/tree/main/bitnami/ms#connect-ms-container-to-an-existing-database).


### Redis

This chart provides support for using Redis to cache database queries and objects improving the website performance.
To enable this feature, set `redis.enabled` parameters to `true`.

It is also possible to use an external cache server rather than installing one inside your cluster. To achieve this, the
chart allows you to specify credentials for an external cache server with
the [`externalCache` parameter](#database-parameters). You should also disable the Redis installation with
the `redis.enabled` option. Here is an example:

```console
redis.enabled=false
externalCache.host=myexternalcachehost
externalCache.port=11211
```

### Ingress

This chart provides support for Ingress resources. If you have an ingress controller installed on your cluster, such
as [nginx-ingress-controller](https://github.com/bitnami/charts/tree/main/bitnami/nginx-ingress-controller)
or [contour](https://github.com/bitnami/charts/tree/main/bitnami/contour) you can utilize the ingress controller to
serve your application.To enable Ingress integration, set `ingress.enabled` to `true`.

The most common scenario is to have one host name mapped to the deployment. In this case, the `ingress.hostname`
property can be used to set the host name. The `ingress.tls` parameter can be used to add the TLS configuration for this
host.

However, it is also possible to have more than one host. To facilitate this, the `ingress.extraHosts` parameter (if
available) can be set with the host names specified as an array. The `ingress.extraTLS` parameter (if available) can
also be used to add the TLS configuration for extra hosts.

> NOTE: For each host specified in the `ingress.extraHosts` parameter, it is necessary to set a name, path, and any
> annotations that the Ingress controller should know about. Not all annotations are supported by all Ingress
> controllers,
>
but [this annotation reference document](https://github.com/kubernetes/ingress-nginx/blob/master/docs/user-guide/nginx-configuration/annotations.md)
> lists the annotations supported by many popular Ingress controllers.

Adding the TLS parameter (where available) will cause the chart to generate HTTPS URLs, and the application will be
available on port 443. The actual TLS secrets do not have to be generated by this chart. However, if TLS is enabled, the
Ingress record will not work until the TLS secret exists.

[Learn more about Ingress controllers](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/).

### TLS secrets

This chart facilitates the creation of TLS secrets for use with the Ingress controller (although this is not mandatory).
There are several common use cases:

- Generate certificate secrets based on chart parameters.
- Enable externally generated certificates.
- Manage application certificates via an external service (
  like [cert-manager](https://github.com/jetstack/cert-manager/)).
- Create self-signed certificates within the chart (if supported).

In the first two cases, a certificate and a key are needed. Files are expected in `.pem` format.

Here is an example of a certificate file:

> NOTE: There may be more than one certificate if there is a certificate chain.

```text
-----BEGIN CERTIFICATE-----
MIID6TCCAtGgAwIBAgIJAIaCwivkeB5EMA0GCSqGSIb3DQEBCwUAMFYxCzAJBgNV
...
jScrvkiBO65F46KioCL9h5tDvomdU1aqpI/CBzhvZn1c0ZTf87tGQR8NK7v7
-----END CERTIFICATE-----
```

Here is an example of a certificate key:

```text
-----BEGIN RSA PRIVATE KEY-----
MIIEogIBAAKCAQEAvLYcyu8f3skuRyUgeeNpeDvYBCDcgq+LsWap6zbX5f8oLqp4
...
wrj2wDbCDCFmfqnSJ+dKI3vFLlEz44sAV8jX/kd4Y6ZTQhlLbYc=
-----END RSA PRIVATE KEY-----
```

- If using Helm to manage the certificates based on the parameters, copy these values into the `certificate` and `key`
  values for a given `*.ingress.secrets` entry.
- If managing TLS secrets separately, it is necessary to create a TLS secret with name `INGRESS_HOSTNAME-tls` (where
  INGRESS_HOSTNAME is a placeholder to be replaced with the hostname you set using the `*.ingress.hostname` parameter).
- If your cluster has a [cert-manager](https://github.com/jetstack/cert-manager) add-on to automate the management and
  issuance of TLS certificates, add to `*.ingress.annotations`
  the [corresponding ones](https://cert-manager.io/docs/usage/ingress/#supported-annotations) for cert-manager.
- If using self-signed certificates created by Helm, set both `*.ingress.tls` and `*.ingress.selfSigned` to `true`.

## Persistence

The [LaraGIS Microservice](https://github.com/laragis/containers/tree/main/laragis/ms) image
stores the Microservice data and configurations at the `/bitnami` path of the container. Persistent
Volume Claims are used to keep the data across deployments.

If you encounter errors when working with persistent volumes, refer to
our [troubleshooting guide for persistent volumes](https://docs.bitnami.com/kubernetes/faq/troubleshooting/troubleshooting-persistence-volumes/).

### Additional environment variables

In case you want to add extra environment variables (useful for advanced operations like custom init scripts), you can
use the `extraEnvVars` property.

```yaml
ms:
extraEnvVars:
  - name: LOG_LEVEL
    value: error
```

Alternatively, you can use a ConfigMap or a Secret with the environment variables. To do so, use the `extraEnvVarsCM` or
the `extraEnvVarsSecret` values.

### Sidecars

If additional containers are needed in the same pod as Microservice (such as additional metrics or
logging exporters), they can be defined using the `sidecars` parameter.

```yaml
sidecars:
  - name: your-image-name
    image: your-image
    imagePullPolicy: Always
    ports:
      - name: portname
        containerPort: 1234
```

If these sidecars export extra ports, extra port definitions can be added using the `service.extraPorts` parameter (
where available), as shown in the example below:

```yaml
service:
  extraPorts:
    - name: extraPort
      port: 11311
      targetPort: 11311
```

> NOTE: This Helm chart already includes sidecar containers for the Prometheus exporters (where applicable). These can
> be activated by adding the `--enable-metrics=true` parameter at deployment time. The `sidecars` parameter should
> therefore only be used for any extra sidecar containers.

If additional init containers are needed in the same pod, they can be defined using the `initContainers` parameter. Here
is an example:

```yaml
initContainers:
  - name: your-image-name
    image: your-image
    imagePullPolicy: Always
    ports:
      - name: portname
        containerPort: 1234
```

Learn more about [sidecar containers](https://kubernetes.io/docs/concepts/workloads/pods/)
and [init containers](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/).

### Pod affinity

This chart allows you to set your custom affinity using the `affinity` parameter. Learn more about Pod affinity in
the [kubernetes documentation](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity).

As an alternative, use one of the preset configurations for pod affinity, pod anti-affinity, and node affinity available
at the [bitnami/common](https://github.com/bitnami/charts/tree/main/bitnami/common#affinities) chart. To do so, set
the `podAffinityPreset`, `podAntiAffinityPreset`, or `nodeAffinityPreset` parameters.

## Parameters

### Global parameters

| Name                                                  | Description                                                                                                                                                                                                                                                                                                                                                         | Value  |
|-------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------|
| `global.imageRegistry`                                | Global Docker image registry                                                                                                                                                                                                                                                                                                                                        | `""`   |
| `global.imagePullSecrets`                             | Global Docker registry secret names as an array                                                                                                                                                                                                                                                                                                                     | `[]`   |
| `global.defaultStorageClass`                          | Global default StorageClass for Persistent Volume(s)                                                                                                                                                                                                                                                                                                                | `""`   |
| `global.compatibility.openshift.adaptSecurityContext` | Adapt the securityContext sections of the deployment to make them compatible with Openshift restricted-v2 SCC: remove runAsUser, runAsGroup and fsGroup and let the platform use their allowed default IDs. Possible values: auto (apply if the detected running cluster is Openshift), force (perform the adaptation always), disabled (do not perform adaptation) | `auto` |

### Common parameters

| Name                     | Description                                                                                  | Value           |
|--------------------------|----------------------------------------------------------------------------------------------|-----------------|
| `kubeVersion`            | Override Kubernetes version                                                                  | `""`            |
| `nameOverride`           | String to partially override common.names.fullname template (will maintain the release name) | `""`            |
| `fullnameOverride`       | String to fully override common.names.fullname template                                      | `""`            |
| `commonLabels`           | Labels to add to all deployed resources                                                      | `{}`            |
| `commonAnnotations`      | Annotations to add to all deployed resources                                                 | `{}`            |
| `clusterDomain`          | Kubernetes Cluster Domain                                                                    | `cluster.local` |
| `extraDeploy`            | Array of extra objects to deploy with the release                                            | `[]`            |
| `diagnosticMode.enabled` | Enable diagnostic mode (all probes will be disabled and the command will be overridden)      | `false`         |
| `diagnosticMode.command` | Command to override all containers in the deployment                                         | `["sleep"]`     |
| `diagnosticMode.args`    | Args to override all containers in the deployment                                            | `["infinity"]`  |

### Microservice Image parameters

| Name                | Description                                                                                                                    | Value                                           |
|---------------------|--------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------|
| `image.registry`    | Microservice image registry                                                                                  | `REGISTRY_NAME`                                 |
| `image.repository`  | Microservice image repository                                                                                | `REPOSITORY_NAME/ms` |
| `image.digest`      | Microservice image digest in the way sha256:aa.... Please note this parameter, if set, will override the tag | `""`                                            |
| `image.pullPolicy`  | Microservice image pull policy                                                                               | `IfNotPresent`                                  |
| `image.pullSecrets` | Microservice image pull secrets                                                                              | `[]`                                            |
| `image.debug`       | Specify if debug values should be set                                                                                          | `false`                                         |

### Microservice Configuration parameters

| Name                 | Description                                                                                   | Value |
|----------------------|-----------------------------------------------------------------------------------------------|-------|
| `command`            | Override default container command (useful when using custom images)                          | `[]`  |
| `args`               | Override default container args (useful when using custom images)                             | `[]`  |
| `extraEnvVars`       | Array with extra environment variables to add to the Microservice container | `[]`  |
| `extraEnvVarsCM`     | Name of existing ConfigMap containing extra env vars                                          | `""`  |
| `extraEnvVarsSecret` | Name of existing Secret containing extra env vars                                             | `""`  |

### Microservice deployment parameters

| Name                                                | Description                                                                                                                                                                                                       | Value            |
|-----------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------|
| `replicaCount`                                      | Number of Microservice replicas to deploy                                                                                                                                                       | `1`              |
| `updateStrategy.type`                               | Microservice deployment strategy type                                                                                                                                                           | `RollingUpdate`  |
| `schedulerName`                                     | Alternate scheduler                                                                                                                                                                                               | `""`             |
| `terminationGracePeriodSeconds`                     | In seconds, time given to the Microservice pod to terminate gracefully                                                                                                                          | `""`             |
| `topologySpreadConstraints`                         | Topology Spread Constraints for pod assignment spread across your cluster among failure-domains. Evaluated as a template                                                                                          | `[]`             |
| `priorityClassName`                                 | Name of the existing priority class to be used by Microservice pods, priority class needs to be created beforehand                                                                              | `""`             |
| `automountServiceAccountToken`                      | Mount Service Account token in pod                                                                                                                                                                                | `false`          |
| `hostAliases`                                       | Microservice pod host aliases                                                                                                                                                                   | `[]`             |
| `extraVolumes`                                      | Optionally specify extra list of additional volumes for Microservice pods                                                                                                                       | `[]`             |
| `extraVolumeMounts`                                 | Optionally specify extra list of additional volumeMounts for Microservice container(s)                                                                                                          | `[]`             |
| `sidecars`                                          | Add additional sidecar containers to the Microservice pod                                                                                                                                       | `[]`             |
| `initContainers`                                    | Add additional init containers to the Microservice pods                                                                                                                                         | `[]`             |
| `podLabels`                                         | Extra labels for Microservice pods                                                                                                                                                              | `{}`             |
| `podAnnotations`                                    | Annotations for Microservice pods                                                                                                                                                               | `{}`             |
| `podAffinityPreset`                                 | Pod affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`                                                                                                                               | `""`             |
| `podAntiAffinityPreset`                             | Pod anti-affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`                                                                                                                          | `soft`           |
| `nodeAffinityPreset.type`                           | Node affinity preset type. Ignored if `affinity` is set. Allowed values: `soft` or `hard`                                                                                                                         | `""`             |
| `nodeAffinityPreset.key`                            | Node label key to match. Ignored if `affinity` is set                                                                                                                                                             | `""`             |
| `nodeAffinityPreset.values`                         | Node label values to match. Ignored if `affinity` is set                                                                                                                                                          | `[]`             |
| `affinity`                                          | Affinity for pod assignment                                                                                                                                                                                       | `{}`             |
| `nodeSelector`                                      | Node labels for pod assignment                                                                                                                                                                                    | `{}`             |
| `tolerations`                                       | Tolerations for pod assignment                                                                                                                                                                                    | `[]`             |
| `resourcesPreset`                                   | Set container resources according to one common preset (allowed values: none, nano, micro, small, medium, large, xlarge, 2xlarge). This is ignored if resources is set (resources is recommended for production). | `micro`          |
| `resources`                                         | Set container requests and limits for different resources like CPU or memory (essential for production workloads)                                                                                                 | `{}`             |
| `containerPorts.http`                               | Microservice HTTP container port                                                                                                                                                                | `8080`           |
| `containerPorts.https`                              | Microservice HTTPS container port                                                                                                                                                               | `8443`           |
| `extraContainerPorts`                               | Optionally specify extra list of additional ports for Microservice container(s)                                                                                                                 | `[]`             |
| `podSecurityContext.enabled`                        | Enabled Microservice pods' Security Context                                                                                                                                                     | `true`           |
| `podSecurityContext.fsGroupChangePolicy`            | Set filesystem group change policy                                                                                                                                                                                | `Always`         |
| `podSecurityContext.sysctls`                        | Set kernel settings using the sysctl interface                                                                                                                                                                    | `[]`             |
| `podSecurityContext.supplementalGroups`             | Set filesystem extra groups                                                                                                                                                                                       | `[]`             |
| `podSecurityContext.fsGroup`                        | Set Microservice pod's Security Context fsGroup                                                                                                                                                 | `1001`           |
| `containerSecurityContext.enabled`                  | Enabled containers' Security Context                                                                                                                                                                              | `true`           |
| `containerSecurityContext.seLinuxOptions`           | Set SELinux options in container                                                                                                                                                                                  | `{}`             |
| `containerSecurityContext.runAsUser`                | Set containers' Security Context runAsUser                                                                                                                                                                        | `1001`           |
| `containerSecurityContext.runAsGroup`               | Set containers' Security Context runAsGroup                                                                                                                                                                       | `1001`           |
| `containerSecurityContext.runAsNonRoot`             | Set container's Security Context runAsNonRoot                                                                                                                                                                     | `true`           |
| `containerSecurityContext.privileged`               | Set container's Security Context privileged                                                                                                                                                                       | `false`          |
| `containerSecurityContext.readOnlyRootFilesystem`   | Set container's Security Context readOnlyRootFilesystem                                                                                                                                                           | `true`           |
| `containerSecurityContext.allowPrivilegeEscalation` | Set container's Security Context allowPrivilegeEscalation                                                                                                                                                         | `false`          |
| `containerSecurityContext.capabilities.drop`        | List of capabilities to be dropped                                                                                                                                                                                | `["ALL"]`        |
| `containerSecurityContext.seccompProfile.type`      | Set container's Security Context seccomp profile                                                                                                                                                                  | `RuntimeDefault` |
| `livenessProbe.enabled`                             | Enable livenessProbe on Microservice containers                                                                                                                                                 | `true`           |
| `livenessProbe.initialDelaySeconds`                 | Initial delay seconds for livenessProbe                                                                                                                                                                           | `120`            |
| `livenessProbe.periodSeconds`                       | Period seconds for livenessProbe                                                                                                                                                                                  | `10`             |
| `livenessProbe.timeoutSeconds`                      | Timeout seconds for livenessProbe                                                                                                                                                                                 | `5`              |
| `livenessProbe.failureThreshold`                    | Failure threshold for livenessProbe                                                                                                                                                                               | `6`              |
| `livenessProbe.successThreshold`                    | Success threshold for livenessProbe                                                                                                                                                                               | `1`              |
| `readinessProbe.enabled`                            | Enable readinessProbe on Microservice containers                                                                                                                                                | `true`           |
| `readinessProbe.initialDelaySeconds`                | Initial delay seconds for readinessProbe                                                                                                                                                                          | `30`             |
| `readinessProbe.periodSeconds`                      | Period seconds for readinessProbe                                                                                                                                                                                 | `10`             |
| `readinessProbe.timeoutSeconds`                     | Timeout seconds for readinessProbe                                                                                                                                                                                | `5`              |
| `readinessProbe.failureThreshold`                   | Failure threshold for readinessProbe                                                                                                                                                                              | `6`              |
| `readinessProbe.successThreshold`                   | Success threshold for readinessProbe                                                                                                                                                                              | `1`              |
| `startupProbe.enabled`                              | Enable startupProbe on Microservice containers                                                                                                                                                  | `false`          |
| `startupProbe.initialDelaySeconds`                  | Initial delay seconds for startupProbe                                                                                                                                                                            | `30`             |
| `startupProbe.periodSeconds`                        | Period seconds for startupProbe                                                                                                                                                                                   | `10`             |
| `startupProbe.timeoutSeconds`                       | Timeout seconds for startupProbe                                                                                                                                                                                  | `5`              |
| `startupProbe.failureThreshold`                     | Failure threshold for startupProbe                                                                                                                                                                                | `6`              |
| `startupProbe.successThreshold`                     | Success threshold for startupProbe                                                                                                                                                                                | `1`              |
| `customLivenessProbe`                               | Custom livenessProbe that overrides the default one                                                                                                                                                               | `{}`             |
| `customReadinessProbe`                              | Custom readinessProbe that overrides the default one                                                                                                                                                              | `{}`             |
| `customStartupProbe`                                | Custom startupProbe that overrides the default one                                                                                                                                                                | `{}`             |
| `lifecycleHooks`                                    | for the Microservice container(s) to automate configuration before or after startup                                                                                                             | `{}`             |

### Traffic Exposure Parameters

| Name                               | Description                                                                                                                                              | Value                                 |
|------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------|
| `service.type`                     | Microservice service type                                                                                                              | `LoadBalancer`                        |
| `service.ports.http`               | Microservice service HTTP port                                                                                                         | `80`                                  |
| `service.ports.https`              | Microservice service HTTPS port                                                                                                        | `443`                                 |
| `service.httpsTargetPort`          | Target port for HTTPS                                                                                                                                    | `https`                               |
| `service.nodePorts.http`           | Node port for HTTP                                                                                                                                       | `""`                                  |
| `service.nodePorts.https`          | Node port for HTTPS                                                                                                                                      | `""`                                  |
| `service.sessionAffinity`          | Control where client requests go, to the same pod or round-robin                                                                                         | `None`                                |
| `service.sessionAffinityConfig`    | Additional settings for the sessionAffinity                                                                                                              | `{}`                                  |
| `service.clusterIP`                | Microservice service Cluster IP                                                                                                        | `""`                                  |
| `service.loadBalancerIP`           | Microservice service Load Balancer IP                                                                                                  | `""`                                  |
| `service.loadBalancerSourceRanges` | Microservice service Load Balancer sources                                                                                             | `[]`                                  |
| `service.externalTrafficPolicy`    | Microservice service external traffic policy                                                                                           | `Cluster`                             |
| `service.annotations`              | Additional custom annotations for Microservice service                                                                                 | `{}`                                  |
| `service.extraPorts`               | Extra port to expose on Microservice service                                                                                           | `[]`                                  |
| `ingress.enabled`                  | Enable ingress record generation for Microservice                                                                                      | `false`                               |
| `ingress.pathType`                 | Ingress path type                                                                                                                                        | `ImplementationSpecific`              |
| `ingress.apiVersion`               | Force Ingress API version (automatically detected if not set)                                                                                            | `""`                                  |
| `ingress.ingressClassName`         | IngressClass that will be be used to implement the Ingress (Kubernetes 1.18+)                                                                            | `""`                                  |
| `ingress.hostname`                 | Default host for the ingress record. The hostname is templated and thus can contain other variable references.                                           | `ms.local` |
| `ingress.path`                     | Default path for the ingress record                                                                                                                      | `/`                                   |
| `ingress.annotations`              | Additional annotations for the Ingress resource. To enable certificate autogeneration, place here your cert-manager annotations.                         | `{}`                                  |
| `ingress.tls`                      | Enable TLS configuration for the host defined at `ingress.hostname` parameter                                                                            | `false`                               |
| `ingress.tlsWwwPrefix`             | Adds www subdomain to default cert                                                                                                                       | `false`                               |
| `ingress.selfSigned`               | Create a TLS secret for this ingress record using self-signed certificates generated by Helm                                                             | `false`                               |
| `ingress.extraHosts`               | An array with additional hostname(s) to be covered with the ingress record. The host names are templated and thus can contain other variable references. | `[]`                                  |
| `ingress.extraPaths`               | An array with additional arbitrary paths that may need to be added to the ingress under the main host                                                    | `[]`                                  |
| `ingress.extraTls`                 | TLS configuration for additional hostname(s) to be covered with this ingress record                                                                      | `[]`                                  |
| `ingress.secrets`                  | Custom TLS certificates as secrets                                                                                                                       | `[]`                                  |
| `ingress.extraRules`               | Additional rules to be covered with this ingress record                                                                                                  | `[]`                                  |

### Persistence Parameters

| Name                                                        | Description                                                                                                                                                                                                                                           | Value                      |
|-------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------|
| `persistence.enabled`                                       | Enable persistence using Persistent Volume Claims                                                                                                                                                                                                     | `true`                     |
| `persistence.storageClass`                                  | Persistent Volume storage class                                                                                                                                                                                                                       | `""`                       |
| `persistence.accessModes`                                   | Persistent Volume access modes                                                                                                                                                                                                                        | `[]`                       |
| `persistence.accessMode`                                    | Persistent Volume access mode (DEPRECATED: use `persistence.accessModes` instead)                                                                                                                                                                     | `ReadWriteOnce`            |
| `persistence.size`                                          | Persistent Volume size                                                                                                                                                                                                                                | `10Gi`                     |
| `persistence.dataSource`                                    | Custom PVC data source                                                                                                                                                                                                                                | `{}`                       |
| `persistence.existingClaim`                                 | The name of an existing PVC to use for persistence                                                                                                                                                                                                    | `""`                       |
| `persistence.selector`                                      | Selector to match an existing Persistent Volume for Microservice data PVC                                                                                                                                                           | `{}`                       |
| `persistence.annotations`                                   | Persistent Volume Claim annotations                                                                                                                                                                                                                   | `{}`                       |
| `volumePermissions.enabled`                                 | Enable init container that changes the owner/group of the PV mount point to `runAsUser:fsGroup`                                                                                                                                                       | `false`                    |
| `volumePermissions.image.registry`                          | OS Shell + Utility image registry                                                                                                                                                                                                                     | `REGISTRY_NAME`            |
| `volumePermissions.image.repository`                        | OS Shell + Utility image repository                                                                                                                                                                                                                   | `REPOSITORY_NAME/os-shell` |
| `volumePermissions.image.digest`                            | OS Shell + Utility image digest in the way sha256:aa.... Please note this parameter, if set, will override the tag                                                                                                                                    | `""`                       |
| `volumePermissions.image.pullPolicy`                        | OS Shell + Utility image pull policy                                                                                                                                                                                                                  | `IfNotPresent`             |
| `volumePermissions.image.pullSecrets`                       | OS Shell + Utility image pull secrets                                                                                                                                                                                                                 | `[]`                       |
| `volumePermissions.resourcesPreset`                         | Set container resources according to one common preset (allowed values: none, nano, micro, small, medium, large, xlarge, 2xlarge). This is ignored if volumePermissions.resources is set (volumePermissions.resources is recommended for production). | `nano`                     |
| `volumePermissions.resources`                               | Set container requests and limits for different resources like CPU or memory (essential for production workloads)                                                                                                                                     | `{}`                       |
| `volumePermissions.containerSecurityContext.seLinuxOptions` | Set SELinux options in container                                                                                                                                                                                                                      | `{}`                       |
| `volumePermissions.containerSecurityContext.runAsUser`      | User ID for the init container                                                                                                                                                                                                                        | `0`                        |

### Other Parameters

| Name                                          | Description                                                                                                                                    | Value   |
|-----------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------|---------|
| `rbac.create`                                 | Create Role and RoleBinding                                                                                                                    | `false` |
| `rbac.rules`                                  | Custom RBAC rules to set                                                                                                                       | `[]`    |
| `serviceAccount.create`                       | Enable creation of ServiceAccount for Microservice pod                                                                       | `true`  |
| `serviceAccount.name`                         | The name of the ServiceAccount to use.                                                                                                         | `""`    |
| `serviceAccount.automountServiceAccountToken` | Allows auto mount of ServiceAccountToken on the serviceAccount created                                                                         | `false` |
| `serviceAccount.annotations`                  | Additional custom annotations for the ServiceAccount                                                                                           | `{}`    |
| `pdb.create`                                  | Enable a Pod Disruption Budget creation                                                                                                        | `true`  |
| `pdb.minAvailable`                            | Minimum number/percentage of pods that should remain scheduled                                                                                 | `""`    |
| `pdb.maxUnavailable`                          | Maximum number/percentage of pods that may be made unavailable. Defaults to `1` if both `pdb.minAvailable` and `pdb.maxUnavailable` are empty. | `""`    |
| `autoscaling.enabled`                         | Enable Horizontal POD autoscaling for Microservice                                                                           | `false` |
| `autoscaling.minReplicas`                     | Minimum number of Microservice replicas                                                                                      | `1`     |
| `autoscaling.maxReplicas`                     | Maximum number of Microservice replicas                                                                                      | `11`    |
| `autoscaling.targetCPU`                       | Target CPU utilization percentage                                                                                                              | `50`    |
| `autoscaling.targetMemory`                    | Target Memory utilization percentage                                                                                                           | `50`    |

### NetworkPolicy parameters

| Name                                    | Description                                                     | Value  |
|-----------------------------------------|-----------------------------------------------------------------|--------|
| `networkPolicy.enabled`                 | Specifies whether a NetworkPolicy should be created             | `true` |
| `networkPolicy.allowExternal`           | Don't require server label for connections                      | `true` |
| `networkPolicy.allowExternalEgress`     | Allow the pod to access any range of port and all destinations. | `true` |
| `networkPolicy.extraIngress`            | Add extra ingress rules to the NetworkPolicy                    | `[]`   |
| `networkPolicy.extraEgress`             | Add extra ingress rules to the NetworkPolicy                    | `[]`   |
| `networkPolicy.ingressNSMatchLabels`    | Labels to match to allow traffic from other namespaces          | `{}`   |
| `networkPolicy.ingressNSPodMatchLabels` | Pod labels to match to allow traffic from other namespaces      | `{}`   |

### Database Parameters

| Name | Description | Value |
|------|-------------|-------|
| `mariadb.enabled`                          | Deploy a MariaDB server to satisfy the applications database
requirements | `true`                                  |
| `mariadb.architecture`                     | MariaDB architecture. Allowed values: `standalone`
or `replication`                                                                                                                                                        | `standalone`                            |
| `mariadb.auth.rootPassword`                | MariaDB root password | `""`                                    |
| `mariadb.auth.database`                    | MariaDB custom database | `bitnami_ms` |
| `mariadb.auth.username`                    | MariaDB custom user name | `bn_ms`      |
| `mariadb.auth.password`                    | MariaDB custom user password | `""`                                    |
| `mariadb.primary.persistence.enabled`      | Enable persistence on MariaDB using PVC(
s)                                                                                                                                                                                 | `true`                                  |
| `mariadb.primary.persistence.storageClass` | Persistent Volume storage
class | `""`                                    |
| `mariadb.primary.persistence.accessModes`  | Persistent Volume access
modes | `[]`                                    |
| `mariadb.primary.persistence.size`         | Persistent Volume size | `8Gi`                                   |
| `mariadb.primary.resourcesPreset`          | Set container resources according to one common preset (allowed values:
none, nano, small, medium, large, xlarge, 2xlarge). This is ignored if primary.resources is set (primary.resources is
recommended for production). | `micro`                                 |
| `mariadb.primary.resources`                | Set container requests and limits for different resources like CPU or
memory (essential for production
workloads)                                                                                                          | `{}`                                    |
| `externalDatabase.host`                    | External Database server host | `localhost`                             |
| `externalDatabase.port`                    | External Database server port | `3306`                                  |
| `externalDatabase.user`                    | External Database username | `bn_ms`      |
| `externalDatabase.password`                | External Database user
password | `""`                                    |
| `externalDatabase.database`                | External Database database
name | `bitnami_ms` |
| `externalDatabase.existingSecret`          | The name of an existing secret with database credentials. Evaluated as a
template | `""`                                    |

| `redis.enabled`                            | Deploy a Redis server for caching database
queries | `false`                                 |
| `redis.auth.enabled`                       | Enable Redis authentication | `false`                                 |
| `redis.auth.username`                      | Redis admin user | `""`                                    |
| `redis.auth.password`                      | Redis admin password | `""`                                    |
| `redis.auth.existingPasswordSecret`        | Existing secret with Redis credentials (must contain a value
for `redis-password`
key)                                                                                                                                     | `""`                                    |
| `redis.service.port`                       | Redis service port | `11211`                                 |
| `redis.resourcesPreset`                    | Set container resources according to one common preset (allowed values:
none, nano, small, medium, large, xlarge, 2xlarge). This is ignored if resources is set (resources is recommended for
production). | `nano`                                  |
| `redis.resources`                          | Set container requests and limits for different resources like CPU or
memory (essential for production
workloads)                                                                                                          | `{}`                                    |
| `externalCache.host`                       | External cache server host | `localhost`                             |
| `externalCache.port`                       | External cache server port | `11211`                                 |


> Note: You need to substitute the placeholders `REGISTRY_NAME` and `REPOSITORY_NAME` with a reference to your Helm
> chart registry and repository. For example, in the case of LaraGIS, you need to
> use `REGISTRY_NAME=registry-1.docker.io`
> and `REPOSITORY_NAME=laragis`.

> NOTE: Once this chart is deployed, it is not possible to change the application's access credentials, such as
> usernames or passwords, using Helm. To change these application credentials after deployment, delete any persistent
> volumes (PVs) used by the chart and re-deploy it, or use the application's built-in administrative tools if available.

Alternatively, a YAML file that specifies the values for the above parameters can be provided while installing the
chart. For example,

```console
helm install my-release -f values.yaml oci://REGISTRY_NAME/REPOSITORY_NAME/ms
```

> Note: You need to substitute the placeholders `REGISTRY_NAME` and `REPOSITORY_NAME` with a reference to your Helm
> chart registry and repository. For example, in the case of LaraGIS, you need to
> use `REGISTRY_NAME=registry-1.docker.io`
> and `REPOSITORY_NAME=laragis`.
> **Tip**:
> You can use the default [values.yaml](https://github.com/laragis/charts/tree/main/laragis/ms/values.yaml)

## Troubleshooting

Find more information about how to deal with common errors related to LaraGIS's Helm charts
in [this troubleshooting guide](https://docs.bitnami.com/general/how-to/troubleshoot-helm-chart-issues).

## Notable changes

## Upgrading

## License

Copyright &copy; 2024 Broadcom. The term "Broadcom" refers to Broadcom Inc. and/or its subsidiaries.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

<http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
