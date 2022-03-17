grafana:
  enabled: true
  image:
    repository: grafana/grafana
    tag: 8.4.2
  grafana.ini:
    server:
      domain: ${grafana_domain}
      root_url: https://${grafana_host}
    auth.gitlab:
      enabled: true
      allow_sign_up: true
      scopes: read_api
      auth_url: https://${gitlab_fqdn}/oauth/authorize
      token_url: https://${gitlab_fqdn}/oauth/token
      api_url: https://${gitlab_fqdn}/api/v4
      allowed_groups: ${groups}
      client_id: ${client_id}
      client_secret: ${client_secret}
      role_attribute_path: "is_admin && 'Admin' || 'Viewer'"
  datasources:
    datasources.yaml:
      apiVersion: 1
      datasources:
      - name: Mojaloop
        type: prometheus
        url: ${prom-mojaloop-url}
        access: proxy
        isDefault: true
  notifiers: 
    notifiers.yaml:
      notifiers:
      - name: slack-notifier
        type: slack
        uid: slack
        org_id: 1
        is_default: true
        settings:
          url: ${grafana-slack-url}
  sidecar:
    dashboards:
      enabled: true
      label: mojaloop_dashboard
      searchNamespace: ${dashboard_namespace}
  ingress:
    enabled: true
    annotations:
      #cert-manager.io/cluster-issuer: letsencrypt
      kubernetes.io/ingress.class: ${ingress_class}
      %{ if external_ingress ~}nginx.ingress.kubernetes.io/whitelist-source-range: ${ingress_whitelist}%{ endif }      
    hosts: 
      - ${grafana_host}
    tls:
      - hosts:
        - ${grafana_host}
prometheus:
  enabled: true
  alertmanager:
    persistentVolume:
      enabled: false
  server:
    persistentVolume:
      enabled: true
      storageClass: ${storage_class_name}
loki:
  persistence:
    enabled: true
    storageClassName: ${storage_class_name}
    size: 5Gi
  config:
    table_manager:
      retention_deletes_enabled: true
      retention_period: 72h     