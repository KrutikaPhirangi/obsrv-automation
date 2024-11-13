set -x

cp -rf ../{global-values.yaml,images.yaml,global-cloud-values-azure.yaml,global-resource-values.yaml} ./

if [ "$2" == "template" ]; then
    cmd="template"
else
    cmd="upgrade -i "
fi

case "$1" in
bootstrap)
    rm -rf bootstrapper
    cp -rf ../bootstrapper ./bootstrapper
    helm $cmd obsrv-bootstrap ./bootstrapper -n obsrv -f global-values.yaml -f images.yaml --create-namespace --debug
    ;;
coredb)
    rm -rf coredb
    cp -rf ../obsrv coredb
    cp -rf ../services/{kafka,postgresql,redis-denorm,redis-dedup,druid-operator} coredb/charts/

    helm $cmd coredb ./coredb -n obsrv -f global-values.yaml -f images.yaml -f global-cloud-values-azure.yaml --debug
    ;;
migrations)
    rm -rf migrations
    cp -rf ../obsrv migrations
    cp -rf ../services/{postgresql-migration,kubernetes-reflector} migrations/charts/

    helm $cmd migrations ./migrations -n obsrv -f global-values.yaml -f images.yaml -f global-cloud-values-azure.yaml --debug
    ;;
monitoring)
    rm -rf monitoring
    cp -rf ../obsrv monitoring
    cp -rf ../services/{promtail,loki,grafana,kube-prometheus-stack,prometheus-node-exporter,kafka-message-exporter,kube-state-metrics,alert-rules} monitoring/charts/

    helm $cmd monitoring ./monitoring -n obsrv -f global-values.yaml -f images.yaml -f global-cloud-values-azure.yaml --debug
    ;;
coreinfra)
    rm -rf coreinfra
    cp -rf ../obsrv coreinfra
    cp -rf ../services/{druid-raw-cluster,flink,spark,superset-keycloak} coreinfra/charts/

    helm $cmd coreinfra ./coreinfra -n obsrv -f global-values.yaml -f images.yaml -f global-cloud-values-azure.yaml --debug
    ;;
obsrvtools)
    rm -rf obsrvtools
    cp -rf ../obsrv obsrvtools
    cp -rf ../services/{command-api,dataset-api,otel-api,grafana-configs,submit-ingestion,system-rules-ingestor,web-console} obsrvtools/charts/

    helm $cmd obsrvtools ./obsrvtools -n obsrv -f global-values.yaml -f images.yaml -f global-cloud-values-azure.yaml --debug
    ;;
additional)
    rm -rf additional
    cp -rf ../obsrv additional
    cp -rf ../services/{secor,druid-exporter,postgresql-exporter,postgresql-backup,letsencrypt-ssl} additional/charts/

    helm $cmd additional ./additional -n obsrv -f global-values.yaml -f images.yaml -f global-cloud-values-azure.yaml --debug
    ;;
additionals)
    rm -rf additionals
    cp -rf ../obsrv additionals
    cp -rf ../services/{azure-exporter,velero} additionals/charts/
    ## secor

    helm $cmd additionals ./additionals -n obsrv -f ../global-values.yaml -f ../images.yaml -f ../global-cloud-values-azure.yaml -f ../sahamati-global-values.yaml --debug
    ;;
exporter)
    rm -rf exporter
    cp -rf ../obsrv exporter
    cp -rf ../services/azure-exporter exporter/charts/

    helm $cmd exporter ./exporter -n obsrv -f ../global-values.yaml -f ../images.yaml -f ../global-cloud-values-azure.yaml -f ../sahamati-global-values.yaml --debug
    ;;
superset-keycloak)
    rm -rf superset-keycloak
    cp -rf ../obsrv superset-keycloak
    cp -rf ../services/superset-keycloak superset-keycloak/charts/

    helm $cmd superset-keycloak ./superset-keycloak -n obsrv -f ../global-values.yaml -f ../images.yaml -f ../sahamati-global-values.yaml --debug
    ;;
letsencrypt-ssl)
    rm -rf letsencrypt-ssl
    cp -rf ../obsrv letsencrypt-ssl
    cp -rf ../services/letsencrypt-ssl letsencrypt-ssl/charts/

    helm $cmd letsencrypt-ssl ./letsencrypt-ssl -n obsrv -f ../images.yaml -f ../global-values.yaml --debug
    ;;
all)
    # bash $0 bootstrap
    # bash $0 coredb
    bash $0 exporter
    bash $0 migrations
    bash $0 monitoring
    bash $0 coreinfra
    bash $0 obsrvapis
    bash $0 obsrvtools
    bash $0 additional
    bash $0 additionals
    ;;
reset)
    helm uninstall additionals -n obsrv
    helm uninstall additional -n obsrv
    helm uninstall obsrvtools -n obsrv
    helm uninstall obsrvapis -n obsrv
    helm uninstall coreinfra -n obsrv
    helm uninstall monitoring -n obsrv
    helm uninstall migrations -n obsrv
    helm uninstall coredb -n obsrv
    helm uninstall obsrv-bootstrap -n obsrv
    ;;
*)
    if [ ! -d "../services/$1" ]; then
        echo "Service $1 not found in ../services"
        exit 1
    fi
    cp -rf ../obsrv ./$1-ind
    cp -rf ../services/$1 ./$1-ind/charts/
    helm $cmd $1-ind ./$1-ind -n obsrv -f global-values.yaml -f images.yaml -f global-cloud-values-azure.yaml --debug
    rm -rf ./$1-ind
    ;;
esac
