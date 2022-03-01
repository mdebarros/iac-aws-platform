# Default values for mojaloop-efk.
# This is a YAML-formatted file.
# Declare variables to be passed into your templates.


image:
  repository: quay.io/fluentd_elasticsearch/fluentd
  ## Specify an imagePullPolicy (Required)
  ## It's recommended to change this to 'Always' if the image tag is 'latest'
  ## ref: http://kubernetes.io/docs/user-guide/images/#updating-images
  tag: v2.6.0
  pullPolicy: IfNotPresent
  ## Optionally specify an array of imagePullSecrets.
  ## Secrets must be manually created in the namespace.
  ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/
  ##
  # pullSecrets:
  #   - myRegistrKeySecretName

## If using AWS Elasticsearch, all requests to ES need to be signed regardless of whether
## one is using Cognito or not. By setting this to true, this chart will install a sidecar
## proxy that takes care of signing all requests being sent to the AWS ES Domain.
awsSigningSidecar:
  enabled: false
  image:
    repository: abutaha/aws-es-proxy
    tag: 0.9

# Specify to use specific priorityClass for pods
# ref: https://kubernetes.io/docs/concepts/configuration/pod-priority-preemption/
# If a Pod cannot be scheduled, the scheduler tries to preempt (evict) lower priority
# Pods to make scheduling of the pending Pod possible.
priorityClassName: ""

# Specify where fluentd can find logs
hostLogDir:
  varLog: /var/log
  dockerContainers: /var/lib/docker/containers
  libSystemdDir: /usr/lib64

## Configure resource requests and limits
## ref: http://kubernetes.io/docs/user-guide/compute-resources/
##
resources: {}
  # limits:
  #   cpu: 100m
  #   memory: 500Mi
  # requests:
  #   cpu: 100m
#   memory: 200Mi

elasticsearch:
  auth:
    enabled: false
    user: "yourUser"
    password: "yourPass"
  bufferChunkLimit: "2M"
  bufferQueueLimit: 8
  hosts: 
  - ${es_host}
  logstashPrefix: "logstash"
  scheme: "http"
  sslVerify: true
  sslVersion: "TLSv1_2"

# If you want to change args of fluentd process
# by example you can add -vv to launch with trace log
fluentdArgs: "--no-supervisor -q"

# If you want to add custom environment variables, use the env dict
# You can then reference these in your config file e.g.:
#     user "#{ENV['OUTPUT_USER']}"
env:
#  KAFKA_OUTPUT_HOST: support-services-kafka.logging
#  KAFKA_OUTPUT_PORT: 9092
# OUTPUT_USER: my_user
# LIVENESS_THRESHOLD_SECONDS: 300
# STUCK_THRESHOLD_SECONDS: 900

# If you want to add custom environment variables from secrets, use the secret list
secret:
# - name: ELASTICSEARCH_PASSWORD
#   secret_name: elasticsearch
#   secret_key: password

rbac:
  create: true

serviceAccount:
  # Specifies whether a ServiceAccount should be created
  create: true
  # The name of the ServiceAccount to use.
  # If not set and create is true, a name is generated using the fullname template
  name: ""

## Specify if a Pod Security Policy for node-exporter must be created
## Ref: https://kubernetes.io/docs/concepts/policy/pod-security-policy/
##
podSecurityPolicy:
  enabled: false
  annotations: {}
    ## Specify pod annotations
    ## Ref: https://kubernetes.io/docs/concepts/policy/pod-security-policy/#apparmor
    ## Ref: https://kubernetes.io/docs/concepts/policy/pod-security-policy/#seccomp
    ## Ref: https://kubernetes.io/docs/concepts/policy/pod-security-policy/#sysctl
    ##
    # seccomp.security.alpha.kubernetes.io/allowedProfileNames: '*'
    # seccomp.security.alpha.kubernetes.io/defaultProfileName: 'docker/default'
  # apparmor.security.beta.kubernetes.io/defaultProfileName: 'runtime/default'

livenessProbe:
  enabled: true

annotations: {}

podAnnotations: {}
  # prometheus.io/scrape: "true"
# prometheus.io/port: "24231"

## DaemonSet update strategy
## Ref: https://kubernetes.io/docs/tasks/manage-daemon/update-daemon-set/
updateStrategy:
  type: RollingUpdate

tolerations: {}
  # - key: node-role.kubernetes.io/master
  #   operator: Exists
#   effect: NoSchedule

affinity: {}
  # nodeAffinity:
  #   requiredDuringSchedulingIgnoredDuringExecution:
  #     nodeSelectorTerms:
  #     - matchExpressions:
  #       - key: node-role.kubernetes.io/master
#         operator: DoesNotExist

nodeSelector: {}

service:
  ports:
    - name: "monitor-agent"
      type: ClusterIP
      port: 24231
    - name: "tcp-ingest"
      type: ClusterIP
      port: 24224
#      - name: "http-ingest"
#        type: ClusterIP
#        port: 9880

serviceMonitor:
  ## If true, a ServiceMonitor CRD is created for a prometheus operator
  ## https://github.com/coreos/prometheus-operator
  ##
  enabled: false
  interval: 10s
  path: /metrics
  port: 24231
  labels: {}

prometheusRule:
  ## If true, a PrometheusRule CRD is created for a prometheus operator
  ## https://github.com/coreos/prometheus-operator
  ##
  enabled: false
  prometheusNamespace: monitoring
  labels: {}
  #  role: alert-rules

configMaps:
  useDefaults:
    systemConf: true
    containersInputConf: true
    systemInputConf: true
    forwardInputConf: false
    monitoringConf: true
    outputConf: true

# can be used to add new config or overwrite the default configmaps completely after the configmaps default has been disabled above
extraConfigMaps:
#   system.conf: |-
#     <system>
#       root_dir /tmp/fluentd-buffers/
#     </system>
  forward.input.conf: |-
    # Forwards the messages sent over TCP and sends it to elasticsearch - https://docs.fluentd.org/input/forward
    <source>
      @id forward
      @type forward
      bind 0.0.0.0
      port 24224
    </source>
  # kafka.output.conf: |-
  #   <match **>
  #     @type kafka_buffered

  #     # list of seed brokers
  #     brokers "#{ENV['KAFKA_OUTPUT_HOST']}":"#{ENV['KAFKA_OUTPUT_PORT']}"

  #     # buffer settings
  #     buffer_type file
  #     buffer_path /var/log/td-agent/buffer/td
  #     flush_interval 3s

  #     # topic settings
  #     default_topic log_messages

  #     # data type settings
  #     output_data_type json
  #     compression_codec gzip

  #     # producer settings
  #     max_send_retries 1
  #     required_acks -1
  #   </match>

#      # Takes the messages sent over HTTP and sends it to elasticsearch - https://docs.fluentd.org/input/http
#      <source>
#        @type http
#        bind 0.0.0.0
#        port 9880
#        body_size_limit 32m
#        keepalive_timeout 10s
#      </source>

# extraVolumes:
#   - name: es-certs
#     secret:
#       defaultMode: 420
#       secretName: es-certs
# extraVolumeMounts:
#   - name: es-certs
#     mountPath: /certs
#     readOnly: true