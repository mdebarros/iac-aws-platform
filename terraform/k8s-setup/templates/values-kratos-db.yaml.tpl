fullnameOverride: "kratos-db"
image:
  registry: docker.io
  repository: bitnami/mysql
  tag: 8.0.26-debian-10-r31
  ## Specify a imagePullPolicy
  ## Defaults to 'Always' if image tag is 'latest', else set to 'IfNotPresent'
  ## ref: http://kubernetes.io/docs/user-guide/images/#pre-pulling-images
  ##
  pullPolicy: IfNotPresent
  ## Optionally specify an array of imagePullSecrets (secrets must be manually created in the namespace)
  ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/
  ## Example:
  ## pullSecrets:
  ##   - myRegistryKeySecretName
  ##
  pullSecrets: []
  ## Set to true if you would like to see extra information on logs
  ## It turns BASH and/or NAMI debugging in the image
  ##
  debug: false
## @param architecture MySQL architecture (`standalone` or `replication`)
##
architecture: standalone
## MySQL Authentication parameters
##
auth:
  ## @param auth.rootPassword Password for the `root` user. Ignored if existing secret is provided
  ## ref: https://github.com/bitnami/bitnami-docker-mysql#setting-the-root-password-on-first-run
  ##
  rootPassword: "rootPassword"
  ## @param auth.database Name for a custom database to create
  ## ref: https://github.com/bitnami/bitnami-docker-mysql/blob/master/README.md#creating-a-database-on-first-run
  ##
  database: kratos
  ## @param auth.username Name for a custom user to create
  ## ref: https://github.com/bitnami/bitnami-docker-mysql/blob/master/README.md#creating-a-database-user-on-first-run
  ##
  username: "user"
  ## @param auth.password Password for the new user. Ignored if existing secret is provided
  ##
  password: "password"
  ## @param auth.replicationUser MySQL replication user
  ## ref: https://github.com/bitnami/bitnami-docker-mysql#setting-up-a-replication-cluster
  ##
  replicationUser: replicator
  ## @param auth.replicationPassword MySQL replication user password. Ignored if existing secret is provided
  ##
  replicationPassword: ""
  ## @param auth.existingSecret Use existing secret for password details. The secret has to contain the keys `mysql-root-password`, `mysql-replication-password` and `mysql-password`
  ## NOTE: When it's set the auth.rootPassword, auth.password, auth.replicationPassword are ignored.
  ##
  existingSecret: ""
  ## @param auth.forcePassword Force users to specify required passwords
  ##
  forcePassword: true
  ## @param auth.usePasswordFiles Mount credentials as files instead of using an environment variable
  ##
  usePasswordFiles: false
  ## @param auth.customPasswordFiles [object] Use custom password files when `auth.usePasswordFiles` is set to `true`. Define path for keys `root` and `user`, also define `replicator` if `architecture` is set to `replication`
  ## Example:
  ## customPasswordFiles:
  ##   root: /vault/secrets/mysql-root
  ##   user: /vault/secrets/mysql-user
  ##   replicator: /vault/secrets/mysql-replicator
  ##
  customPasswordFiles: {}
## @param initdbScripts [object] Dictionary of initdb scripts
## Specify dictionary of scripts to be run at first boot
## Example:
## initdbScripts:
##   my_init_script.sh: |
##      #!/bin/bash
##      echo "Do something."
##
# initdbScripts: {}
initdbScripts:
    # This script enables legacy authentication for MySQL v8. NodeJS MySQL Client currently does not support authentication plugins, reference: https://github.com/mysqljs/mysql/pull/2233
    enableLegacyAuth.sql: |-
      ALTER USER 'user'@'%' IDENTIFIED WITH mysql_native_password BY 'password';
## @param initdbScriptsConfigMap ConfigMap with the initdb scripts (Note: Overrides `initdbScripts`)
##
initdbScriptsConfigMap: ""

## @section MySQL Primary parameters

primary:
  ## @param primary.command [array] Override default container command on MySQL Primary container(s) (useful when using custom images)
  ##
  command: []
  ## @param primary.args [array] Override default container args on MySQL Primary container(s) (useful when using custom images)
  ##
  args: []
  ## @param primary.hostAliases [array] Deployment pod host aliases
  ## https://kubernetes.io/docs/concepts/services-networking/add-entries-to-pod-etc-hosts-with-host-aliases/
  ##
  hostAliases: []
  ## @param primary.configuration [string] Configure MySQL Primary with a custom my.cnf file
  ## ref: https://mysql.com/kb/en/mysql/configuring-mysql-with-mycnf/#example-of-configuration-file
  ##
  configuration: |-
    [mysqld]
    default_authentication_plugin=mysql_native_password
    skip-name-resolve
    explicit_defaults_for_timestamp
    basedir=/opt/bitnami/mysql
    plugin_dir=/opt/bitnami/mysql/lib/plugin
    port=3306
    socket=/opt/bitnami/mysql/tmp/mysql.sock
    datadir=/bitnami/mysql/data
    tmpdir=/opt/bitnami/mysql/tmp
    max_allowed_packet=16M
    bind-address=0.0.0.0
    pid-file=/opt/bitnami/mysql/tmp/mysqld.pid
    log-error=/opt/bitnami/mysql/logs/mysqld.log
    character-set-server=UTF8
    collation-server=utf8_general_ci

    [client]
    port=3306
    socket=/opt/bitnami/mysql/tmp/mysql.sock
    default-character-set=UTF8
    plugin_dir=/opt/bitnami/mysql/lib/plugin

    [manager]
    port=3306
    socket=/opt/bitnami/mysql/tmp/mysql.sock
    pid-file=/opt/bitnami/mysql/tmp/mysqld.pid
  ## @param primary.existingConfiguration Name of existing ConfigMap with MySQL Primary configuration.
  ## NOTE: When it's set the 'configuration' parameter is ignored
  ##
  existingConfiguration: ""
  ## @param primary.updateStrategy Update strategy type for the MySQL primary statefulset
  ## ref: https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#update-strategies
  ##
  updateStrategy: RollingUpdate
  ## @param primary.rollingUpdatePartition Partition update strategy for MySQL Primary statefulset
  ## https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#partitions
  ##
  rollingUpdatePartition: ""
  ## @param primary.podAnnotations [object] Additional pod annotations for MySQL primary pods
  ## ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/
  ##
  podAnnotations: {}
  ## @param primary.podAffinityPreset MySQL primary pod affinity preset. Ignored if `primary.affinity` is set. Allowed values: `soft` or `hard`
  ## ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#inter-pod-affinity-and-anti-affinity
  ##
  podAffinityPreset: ""
  ## @param primary.podAntiAffinityPreset MySQL primary pod anti-affinity preset. Ignored if `primary.affinity` is set. Allowed values: `soft` or `hard`
  ## ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#inter-pod-affinity-and-anti-affinity
  ##
  podAntiAffinityPreset: soft
  ## MySQL Primary node affinity preset
  ## ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#node-affinity
  ##
  nodeAffinityPreset:
    ## @param primary.nodeAffinityPreset.type MySQL primary node affinity preset type. Ignored if `primary.affinity` is set. Allowed values: `soft` or `hard`
    ##
    type: ""
    ## @param primary.nodeAffinityPreset.key MySQL primary node label key to match Ignored if `primary.affinity` is set.
    ## E.g.
    ## key: "kubernetes.io/e2e-az-name"
    ##
    key: ""
    ## @param primary.nodeAffinityPreset.values [array] MySQL primary node label values to match. Ignored if `primary.affinity` is set.
    ## E.g.
    ## values:
    ##   - e2e-az1
    ##   - e2e-az2
    ##
    values: []
  ## @param primary.affinity [object] Affinity for MySQL primary pods assignment
  ## ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity
  ## Note: podAffinityPreset, podAntiAffinityPreset, and  nodeAffinityPreset will be ignored when it's set
  ##
  affinity: {}
  ## @param primary.nodeSelector [object] Node labels for MySQL primary pods assignment
  ## ref: https://kubernetes.io/docs/user-guide/node-selection/
  ##
  nodeSelector: {}
  ## @param primary.tolerations [array] Tolerations for MySQL primary pods assignment
  ## ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/
  ##
  tolerations: []
  ## MySQL primary Pod security context
  ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-pod
  ## @param primary.podSecurityContext.enabled Enable security context for MySQL primary pods
  ## @param primary.podSecurityContext.fsGroup Group ID for the mounted volumes' filesystem
  ##
  podSecurityContext:
    enabled: true
    fsGroup: 1001
  ## MySQL primary container security context
  ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-container
  ## @param primary.containerSecurityContext.enabled MySQL primary container securityContext
  ## @param primary.containerSecurityContext.runAsUser User ID for the MySQL primary container
  ##
  containerSecurityContext:
    enabled: true
    runAsUser: 1001
  ## MySQL primary container's resource requests and limits
  ## ref: http://kubernetes.io/docs/user-guide/compute-resources/
  ## We usually recommend not to specify default resources and to leave this as a conscious
  ## choice for the user. This also increases chances charts run on environments with little
  ## resources, such as Minikube. If you do want to specify resources, uncomment the following
  ## lines, adjust them as necessary, and remove the curly braces after 'resources:'.
  ## @param primary.resources.limits [object] The resources limits for MySQL primary containers
  ## @param primary.resources.requests [object] The requested resources for MySQL primary containers
  ##
  resources:
    ## Example:
    ## limits:
    ##    cpu: 250m
    ##    memory: 256Mi
    limits: {}
    ## Examples:
    ## requests:
    ##    cpu: 250m
    ##    memory: 256Mi
    requests: {}
  ## Configure extra options for liveness probe
  ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/#configure-probes
  ## @param primary.livenessProbe.enabled Enable livenessProbe
  ## @param primary.livenessProbe.initialDelaySeconds Initial delay seconds for livenessProbe
  ## @param primary.livenessProbe.periodSeconds Period seconds for livenessProbe
  ## @param primary.livenessProbe.timeoutSeconds Timeout seconds for livenessProbe
  ## @param primary.livenessProbe.failureThreshold Failure threshold for livenessProbe
  ## @param primary.livenessProbe.successThreshold Success threshold for livenessProbe
  ##
  livenessProbe:
    enabled: true
    initialDelaySeconds: 5
    periodSeconds: 10
    timeoutSeconds: 1
    failureThreshold: 3
    successThreshold: 1
  ## Configure extra options for readiness probe
  ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/#configure-probes
  ## @param primary.readinessProbe.enabled Enable readinessProbe
  ## @param primary.readinessProbe.initialDelaySeconds Initial delay seconds for readinessProbe
  ## @param primary.readinessProbe.periodSeconds Period seconds for readinessProbe
  ## @param primary.readinessProbe.timeoutSeconds Timeout seconds for readinessProbe
  ## @param primary.readinessProbe.failureThreshold Failure threshold for readinessProbe
  ## @param primary.readinessProbe.successThreshold Success threshold for readinessProbe
  ##
  readinessProbe:
    enabled: true
    initialDelaySeconds: 5
    periodSeconds: 10
    timeoutSeconds: 1
    failureThreshold: 3
    successThreshold: 1
  ## Configure extra options for startupProbe probe
  ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/#configure-probes
  ## @param primary.startupProbe.enabled Enable startupProbe
  ## @param primary.startupProbe.initialDelaySeconds Initial delay seconds for startupProbe
  ## @param primary.startupProbe.periodSeconds Period seconds for startupProbe
  ## @param primary.startupProbe.timeoutSeconds Timeout seconds for startupProbe
  ## @param primary.startupProbe.failureThreshold Failure threshold for startupProbe
  ## @param primary.startupProbe.successThreshold Success threshold for startupProbe
  ##
  startupProbe:
    enabled: true
    initialDelaySeconds: 15
    periodSeconds: 10
    timeoutSeconds: 1
    failureThreshold: 10
    successThreshold: 1
  ## @param primary.customLivenessProbe [object] Override default liveness probe for MySQL primary containers
  ##
  customLivenessProbe: {}
  ## @param primary.customReadinessProbe [object] Override default readiness probe for MySQL primary containers
  ##
  customReadinessProbe: {}
  ## @param primary.customStartupProbe [object] Override default startup probe for MySQL primary containers
  ##
  customStartupProbe: {}
  ## @param primary.extraFlags MySQL primary additional command line flags
  ## Can be used to specify command line flags, for example:
  ## E.g.
  ## extraFlags: "--max-connect-errors=1000 --max_connections=155"
  ##
  extraFlags: ""
  ## @param primary.extraEnvVars [array] Extra environment variables to be set on MySQL primary containers
  ## E.g.
  ## extraEnvVars:
  ##  - name: TZ
  ##    value: "Europe/Paris"
  ##
  extraEnvVars: []
  ## @param primary.extraEnvVarsCM Name of existing ConfigMap containing extra env vars for MySQL primary containers
  ##
  extraEnvVarsCM: ""
  ## @param primary.extraEnvVarsSecret Name of existing Secret containing extra env vars for MySQL primary containers
  ##
  extraEnvVarsSecret: ""
  ## Enable persistence using Persistent Volume Claims
  ## ref: http://kubernetes.io/docs/user-guide/persistent-volumes/
  ##
  persistence:
    ## @param primary.persistence.enabled Enable persistence on MySQL primary replicas using a `PersistentVolumeClaim`. If false, use emptyDir
    ##
    enabled: false
    ## @param primary.persistence.existingClaim Name of an existing `PersistentVolumeClaim` for MySQL primary replicas
    ## NOTE: When it's set the rest of persistence parameters are ignored
    ##
    existingClaim: ""
    ## @param primary.persistence.storageClass MySQL primary persistent volume storage Class
    ## If defined, storageClassName: <storageClass>
    ## If set to "-", storageClassName: "", which disables dynamic provisioning
    ## If undefined (the default) or set to null, no storageClassName spec is
    ##   set, choosing the default provisioner.  (gp2 on AWS, standard on
    ##   GKE, AWS & OpenStack)
    ##
    storageClass: ""
    ## @param primary.persistence.annotations [object] MySQL primary persistent volume claim annotations
    ##
    annotations: {}
    ## @param primary.persistence.accessModes MySQL primary persistent volume access Modes
    ##
    accessModes:
      - ReadWriteOnce
    ## @param primary.persistence.size MySQL primary persistent volume size
    ##
    size: 8Gi
    ## @param primary.persistence.selector [object] Selector to match an existing Persistent Volume
    ## selector:
    ##   matchLabels:
    ##     app: my-app
    ##
    selector: {}
  ## @param primary.extraVolumes [array] Optionally specify extra list of additional volumes to the MySQL Primary pod(s)
  ##
  extraVolumes: []
  ## @param primary.extraVolumeMounts [array] Optionally specify extra list of additional volumeMounts for the MySQL Primary container(s)
  ##
  extraVolumeMounts: []
  ## @param primary.initContainers [array] Add additional init containers for the MySQL Primary pod(s)
  ##
  initContainers: []
  ## @param primary.sidecars [array] Add additional sidecar containers for the MySQL Primary pod(s)
  ##
  sidecars: []
  ## MySQL Primary Service parameters
  ##
  service:
    ## @param primary.service.type MySQL Primary K8s service type
    ##
    type: ClusterIP
    ## @param primary.service.port MySQL Primary K8s service port
    ##
    port: 3306
    ## @param primary.service.nodePort MySQL Primary K8s service node port
    ## ref: https://kubernetes.io/docs/concepts/services-networking/service/#type-nodeport
    ##
    nodePort: ""
    ## @param primary.service.clusterIP MySQL Primary K8s service clusterIP IP
    ## e.g:
    ## clusterIP: None
    ##
    clusterIP: ""
    ## @param primary.service.loadBalancerIP MySQL Primary loadBalancerIP if service type is `LoadBalancer`
    ## Set the LoadBalancer service type to internal only
    ## ref: https://kubernetes.io/docs/concepts/services-networking/service/#internal-load-balancer
    ##
    loadBalancerIP: ""
    ## @param primary.service.externalTrafficPolicy Enable client source IP preservation
    ## ref http://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip
    ##
    externalTrafficPolicy: Cluster
    ## @param primary.service.loadBalancerSourceRanges [array] Addresses that are allowed when MySQL Primary service is LoadBalancer
    ## https://kubernetes.io/docs/tasks/access-application-cluster/configure-cloud-provider-firewall/#restrict-access-for-loadbalancer-service
    ## E.g.
    ## loadBalancerSourceRanges:
    ##   - 10.10.10.0/24
    ##
    loadBalancerSourceRanges: []
    ## @param primary.service.annotations [object] Provide any additional annotations which may be required
    ##
    annotations: {}
  ## MySQL primary Pod Disruption Budget configuration
  ## ref: https://kubernetes.io/docs/tasks/run-application/configure-pdb/
  ##
  pdb:
    ## @param primary.pdb.enabled Enable/disable a Pod Disruption Budget creation for MySQL primary pods
    ##
    enabled: false
    ## @param primary.pdb.minAvailable Minimum number/percentage of MySQL primary pods that should remain scheduled
    ##
    minAvailable: 1
    ## @param primary.pdb.maxUnavailable Maximum number/percentage of MySQL primary pods that may be made unavailable
    ##
    maxUnavailable: ""
  ## @param primary.podLabels [object] MySQL Primary pod label. If labels are same as commonLabels , this will take precedence
  ##
  podLabels: {}

## @section RBAC parameters

## MySQL pods ServiceAccount
## ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/
##
serviceAccount:
  ## @param serviceAccount.create Enable the creation of a ServiceAccount for MySQL pods
  ##
  create: true
  ## @param serviceAccount.name Name of the created ServiceAccount
  ## If not set and create is true, a name is generated using the mysql.fullname template
  ##
  name: ""
  ## @param serviceAccount.annotations [object] Annotations for MySQL Service Account
  ##
  annotations: {}
## Role Based Access
## ref: https://kubernetes.io/docs/admin/authorization/rbac/
##
rbac:
  ## @param rbac.create Whether to create & use RBAC resources or not
  ##
  create: false

## @section Network Policy

## MySQL Nework Policy configuration
##
networkPolicy:
  ## @param networkPolicy.enabled Enable creation of NetworkPolicy resources
  ##
  enabled: false
  ## @param networkPolicy.allowExternal The Policy model to apply.
  ## When set to false, only pods with the correct
  ## client label will have network access to the port MySQL is listening
  ## on. When true, MySQL will accept connections from any source
  ## (with the correct destination port).
  ##
  allowExternal: true
  ## @param networkPolicy.explicitNamespacesSelector [object] A Kubernetes LabelSelector to explicitly select namespaces from which ingress traffic could be allowed to MySQL
  ## If explicitNamespacesSelector is missing or set to {}, only client Pods that are in the networkPolicy's namespace
  ## and that match other criteria, the ones that have the good label, can reach the DB.
  ## But sometimes, we want the DB to be accessible to clients from other namespaces, in this case, we can use this
  ## LabelSelector to select these namespaces, note that the networkPolicy's namespace should also be explicitly added.
  ##
  ## Example:
  ## explicitNamespacesSelector:
  ##   matchLabels:
  ##     role: frontend
  ##   matchExpressions:
  ##    - {key: role, operator: In, values: [frontend]}
  ##
  explicitNamespacesSelector: {}

## @section Volume Permissions parameters

## Init containers parameters:
## volumePermissions: Change the owner and group of the persistent volume mountpoint to runAsUser:fsGroup values from the securityContext section.
##
volumePermissions:
  ## @param volumePermissions.enabled Enable init container that changes the owner and group of the persistent volume(s) mountpoint to `runAsUser:fsGroup`
  ##
  enabled: false
  ## @param volumePermissions.image.registry Init container volume-permissions image registry
  ## @param volumePermissions.image.repository Init container volume-permissions image repository
  ## @param volumePermissions.image.tag Init container volume-permissions image tag (immutable tags are recommended)
  ## @param volumePermissions.image.pullPolicy Init container volume-permissions image pull policy
  ## @param volumePermissions.image.pullSecrets [array] Specify docker-registry secret names as an array
  ##
  image:
    registry: docker.io
    repository: bitnami/bitnami-shell
    tag: 10-debian-10-r172
    pullPolicy: Always
    ## Optionally specify an array of imagePullSecrets.
    ## Secrets must be manually created in the namespace.
    ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/
    ## e.g:
    ## pullSecrets:
    ##   - myRegistryKeySecretName
    ##
    pullSecrets: []
  ## @param volumePermissions.resources [object] Init container volume-permissions resources
  ##
  resources: {}

## @section Metrics parameters

## Mysqld Prometheus exporter parameters
##
metrics:
  ## @param metrics.enabled Start a side-car prometheus exporter
  ##
  enabled: true
  ## @param metrics.image.registry Exporter image registry
  ## @param metrics.image.repository Exporter image repository
  ## @param metrics.image.tag Exporter image tag (immutable tags are recommended)
  ## @param metrics.image.pullPolicy Exporter image pull policy
  ## @param metrics.image.pullSecrets [array] Specify docker-registry secret names as an array
  ##
  image:
    registry: docker.io
    repository: bitnami/mysqld-exporter
    tag: 0.13.0-debian-10-r75
    pullPolicy: IfNotPresent
    ## Optionally specify an array of imagePullSecrets.
    ## Secrets must be manually created in the namespace.
    ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/
    ## e.g:
    ## pullSecrets:
    ##   - myRegistryKeySecretName
    ##
    pullSecrets: []
  ## MySQL Prometheus exporter service parameters
  ## Mysqld Prometheus exporter liveness and readiness probes
  ## ref: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#container-probes
  ## @param metrics.service.type Kubernetes service type for MySQL Prometheus Exporter
  ## @param metrics.service.port MySQL Prometheus Exporter service port
  ## @param metrics.service.annotations [object] Prometheus exporter service annotations
  ##
  service:
    type: ClusterIP
    port: 9104
    annotations:
      prometheus.io/scrape: "true"
      prometheus.io/port: "{{ .Values.metrics.service.port }}"
  ## @param metrics.extraArgs.primary [array] Extra args to be passed to mysqld_exporter on Primary pods
  ## @param metrics.extraArgs.secondary [array] Extra args to be passed to mysqld_exporter on Secondary pods
  ## ref: https://github.com/prometheus/mysqld_exporter/
  ## E.g.
  ## - --collect.auto_increment.columns
  ## - --collect.binlog_size
  ## - --collect.engine_innodb_status
  ## - --collect.engine_tokudb_status
  ## - --collect.global_status
  ## - --collect.global_variables
  ## - --collect.info_schema.clientstats
  ## - --collect.info_schema.innodb_metrics
  ## - --collect.info_schema.innodb_tablespaces
  ## - --collect.info_schema.innodb_cmp
  ## - --collect.info_schema.innodb_cmpmem
  ## - --collect.info_schema.processlist
  ## - --collect.info_schema.processlist.min_time
  ## - --collect.info_schema.query_response_time
  ## - --collect.info_schema.tables
  ## - --collect.info_schema.tables.databases
  ## - --collect.info_schema.tablestats
  ## - --collect.info_schema.userstats
  ## - --collect.perf_schema.eventsstatements
  ## - --collect.perf_schema.eventsstatements.digest_text_limit
  ## - --collect.perf_schema.eventsstatements.limit
  ## - --collect.perf_schema.eventsstatements.timelimit
  ## - --collect.perf_schema.eventswaits
  ## - --collect.perf_schema.file_events
  ## - --collect.perf_schema.file_instances
  ## - --collect.perf_schema.indexiowaits
  ## - --collect.perf_schema.tableiowaits
  ## - --collect.perf_schema.tablelocks
  ## - --collect.perf_schema.replication_group_member_stats
  ## - --collect.slave_status
  ## - --collect.slave_hosts
  ## - --collect.heartbeat
  ## - --collect.heartbeat.database
  ## - --collect.heartbeat.table
  ##
  extraArgs:
    primary: []
    secondary: []
  ## Mysqld Prometheus exporter resource requests and limits
  ## ref: http://kubernetes.io/docs/user-guide/compute-resources/
  ## We usually recommend not to specify default resources and to leave this as a conscious
  ## choice for the user. This also increases chances charts run on environments with little
  ## resources, such as Minikube. If you do want to specify resources, uncomment the following
  ## lines, adjust them as necessary, and remove the curly braces after 'resources:'.
  ## @param metrics.resources.limits [object] The resources limits for MySQL prometheus exporter containers
  ## @param metrics.resources.requests [object] The requested resources for MySQL prometheus exporter containers
  ##
  resources:
    ## Example:
    ## limits:
    ##    cpu: 100m
    ##    memory: 256Mi
    limits: {}
    ## Examples:
    ## requests:
    ##    cpu: 100m
    ##    memory: 256Mi
    requests: {}
  ## Mysqld Prometheus exporter liveness probe
  ## ref: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#container-probes
  ## @param metrics.livenessProbe.enabled Enable livenessProbe
  ## @param metrics.livenessProbe.initialDelaySeconds Initial delay seconds for livenessProbe
  ## @param metrics.livenessProbe.periodSeconds Period seconds for livenessProbe
  ## @param metrics.livenessProbe.timeoutSeconds Timeout seconds for livenessProbe
  ## @param metrics.livenessProbe.failureThreshold Failure threshold for livenessProbe
  ## @param metrics.livenessProbe.successThreshold Success threshold for livenessProbe
  ##
  livenessProbe:
    enabled: true
    initialDelaySeconds: 120
    periodSeconds: 10
    timeoutSeconds: 1
    successThreshold: 1
    failureThreshold: 3
  ## Mysqld Prometheus exporter readiness probe
  ## ref: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#container-probes
  ## @param metrics.readinessProbe.enabled Enable readinessProbe
  ## @param metrics.readinessProbe.initialDelaySeconds Initial delay seconds for readinessProbe
  ## @param metrics.readinessProbe.periodSeconds Period seconds for readinessProbe
  ## @param metrics.readinessProbe.timeoutSeconds Timeout seconds for readinessProbe
  ## @param metrics.readinessProbe.failureThreshold Failure threshold for readinessProbe
  ## @param metrics.readinessProbe.successThreshold Success threshold for readinessProbe
  ##
  readinessProbe:
    enabled: true
    initialDelaySeconds: 30
    periodSeconds: 10
    timeoutSeconds: 1
    successThreshold: 1
    failureThreshold: 3
  ## Prometheus Service Monitor
  ## ref: https://github.com/coreos/prometheus-operator
  ##
  serviceMonitor:
    ## @param metrics.serviceMonitor.enabled Create ServiceMonitor Resource for scraping metrics using PrometheusOperator
    ##
    enabled: false
    ## @param metrics.serviceMonitor.namespace Specify the namespace in which the serviceMonitor resource will be created
    ##
    namespace: ""
    ## @param metrics.serviceMonitor.interval Specify the interval at which metrics should be scraped
    ##
    interval: 30s
    ## @param metrics.serviceMonitor.scrapeTimeout Specify the timeout after which the scrape is ended
    ## e.g:
    ## scrapeTimeout: 30s
    ##
    scrapeTimeout: ""
    ## @param metrics.serviceMonitor.relabellings [array] Specify Metric Relabellings to add to the scrape endpoint
    ##
    relabellings: []
    ## @param metrics.serviceMonitor.honorLabels Specify honorLabels parameter to add the scrape endpoint
    ##
    honorLabels: false
    ## @param metrics.serviceMonitor.additionalLabels [object] Used to pass Labels that are used by the Prometheus installed in your cluster to select Service Monitors to work with
    ## ref: https://github.com/coreos/prometheus-operator/blob/master/Documentation/api.md#prometheusspec
    ##
    additionalLabels: {}
