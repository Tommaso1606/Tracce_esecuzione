#!/bin/sh
# 60 sec / 5 sec = 12 * n (min) => num esecuzioni


#numSamples=$((12*$1))
numUser=10
i=1
run=3600s

PATHS=`sudo ls /var/lib/docker/containers`
NUM_CONTAINERS=`echo "${PATHS}" | wc -l`


echo "Cleaning log files..."
for CONTAINER in $PATHS
do
    sudo truncate -s 0 /var/lib/docker/containers/$CONTAINER/$CONTAINER-json.log
done 

echo "...Done"


#for i in $(seq 1 1 $numSamples)
#do  
#   esecuzione variabile up/down
    # if (($i > $numSamples/2))
    # then
    #     ((numUser=numUser-5))
    # else
    #     ((numUser=numUser+5))
    # fi

#   esecuzione singola anomalia
#    if (($i > $numSamples/2))
#    then
#        ((numUser=150))
#    fi

    #   esecuzione singola anomalia
 #   if (($i > ($numSamples/2)+6))
 #   then
 #       ((numUser=10))
 #   fi

    echo "Executing workload ..."
    echo "-------------------------------------------------------------------------------"
    echo "NUMUSER: $numUser"
#    echo "Esecuzione: $i"
    echo "-------------------------------------------------------------------------------"
    locust --headless --users $numUser --spawn-rate $numUser -H http://localhost:8080 --run-time $run --csv=esec_$i
#    sudo docker container stats --no-stream >> docker.csv
    echo "...Done"

#done   


echo "Retreiving log files..."

for CONTAINER in $PATHS
do
    CONTAINER_ID=`sudo cat /var/lib/docker/containers/$CONTAINER/hostname`
    CONTAINER_NAME=`sudo docker ps --format "{{.ID}} {{.Names}}" | grep ${CONTAINER_ID} | awk '{print $2}'`
    sudo cp /var/lib/docker/containers/${CONTAINER}/${CONTAINER}-json.log ./${CONTAINER_NAME}.log
    sudo chmod 666 ./${CONTAINER_NAME}.log

done

mkdir -p execution_$i
mv *.log execution_$i
mv *.csv execution_$i

echo "...Done"


#Elimino le vecchie tracce
rm -rf traces

# Creo la cartella per le nuove tracce
mkdir traces

#ts-ui-dashboard
curl -s http://localhost:16686/api/traces?service=ts-ui-dashboard | jq > traces/trace-ts-ui-dashboard.json 
echo "Tracce servizio ts-ui-dashboard salvate"

#ts-auth-service
curl -s http://localhost:16686/api/traces?service=ts-auth-service | jq > traces/trace-ts-auth-service.json 
echo "Tracce servizio ts-auth-service salvate"

#ts-user-service
curl -s http://localhost:16686/api/traces?service=ts-user-service | jq > traces/trace-ts-user-service.json 
echo "Tracce servizio ts-user-service salvate"

#ts-route-service
curl -s http://localhost:16686/api/traces?service=ts-route-service | jq > traces/trace-ts-route-service.json
echo "Tracce servizio ts-route-service salvate"

#ts-verification-code-service
curl -s http://localhost:16686/api/traces?service=ts-verification-code-service | jq > traces/trace-ts-verification-code-service.json
echo "Tracce servizio ts-verification-code-service salvate"

#ts-contacts-service
curl -s http://localhost:16686/api/traces?service=ts-contacts-service | jq > traces/trace-ts-contacts-service.json 
echo "Tracce servizio ts-contacts-service salvate"

#ts-order-service
curl -s http://localhost:16686/api/traces?service=ts-order-service | jq > traces/trace-ts-order-service.json 
echo "Tracce servizio ts-order-service salvate"

#ts-order-other-service
curl -s http://localhost:16686/api/traces?service=ts-order-other-service | jq > traces/trace-ts-order-other-service.json 
echo "Tracce servizio ts-order-other-service salvate"

#ts-config-service
curl -s http://localhost:16686/api/traces?service=ts-config-service | jq > traces/trace-ts-config-service.json 
echo "Tracce servizio ts-config-service salvate"

#ts-station-service
curl -s http://localhost:16686/api/traces?service=ts-station-service | jq > traces/trace-ts-station-service.json 
echo "Tracce servizio ts-station-service salvate"

#ts-train-service
curl -s http://localhost:16686/api/traces?service=ts-train-service | jq > traces/trace-ts-train-service.json 
echo "Tracce servizio ts-train-service salvate"

#ts-travel-service
curl -s http://localhost:16686/api/traces?service=ts-travel-service | jq > traces/trace-ts-travel-service.json
echo "Tracce servizio ts-travel-service salvate"

#ts-travel2-service
curl -s http://localhost:16686/api/traces?service=ts-travel2-service | jq > traces/trace-ts-travel2-service.json 
echo "Tracce servizio ts-travel2-service salvate"

#ts-preserve-service
curl -s http://localhost:16686/api/traces?service=ts-preserve-service | jq > traces/trace-ts-preserve-service.json 
echo "Tracce servizio ts-preserve-service salvate"

#ts-preserve-other-service
curl -s http://localhost:16686/api/traces?service=ts-preserve-other-service | jq > traces/trace-ts-preserve-other-service.json 
echo "Tracce servizio ts-preserve-other-service salvate"

#ts-basic-service
curl -s http://localhost:16686/api/traces?service=ts-basic-service | jq > traces/trace-ts-basic-service.json 
echo "Tracce servizio ts-basic-service salvate"

#ts-ticketinfo-service
curl -s http://localhost:16686/api/traces?service=ts-ticketinfo-service | jq > traces/trace-ts-ticketinfo-service.json 
echo "Tracce servizio ts-ticketinfo-service salvate"

#ts-price-service
curl -s http://localhost:16686/api/traces?service=ts-price-service | jq > traces/trace-ts-price-service.json 
echo "Tracce servizio ts-price-service salvate"

#ts-notification-service
curl -s http://localhost:16686/api/traces?service=ts-notification-service | jq > traces/trace-ts-notification-service.json 
echo "Tracce servizio ts-notification-service salvate"

#ts-security-service
curl -s http://localhost:16686/api/traces?service=ts-security-service | jq > traces/trace-ts-security-service.json 
echo "Tracce servizio ts-security-service salvate"

#ts-inside-payment-service
curl -s http://localhost:16686/api/traces?service=ts-inside-payment-service | jq > traces/trace-ts-inside-payment-service.json 
echo "Tracce servizio ts-inside-payment-service salvate"

#ts-execute-service
curl -s http://localhost:16686/api/traces?service=ts-execute-service | jq > traces/trace-ts-execute-service.json 
echo "Tracce servizio ts-execute-service salvate"

#ts-payment-service
curl -s http://localhost:16686/api/traces?service=ts-payment-service | jq > traces/trace-ts-payment-service.json
echo "Tracce servizio ts-payment-service salvate"

#ts-rebook-service
curl -s http://localhost:16686/api/traces?service=ts-rebook-service | jq > traces/trace-ts-rebook-service.json
echo "Tracce servizio ts-rebook-service salvate"

#ts-cancel-service
curl -s http://localhost:16686/api/traces?service=ts-cancel-service | jq > traces/trace-ts-cancel-service.json
echo "Tracce servizio ts-cancel-service salvate"

#ts-assurance-service
curl -s http://localhost:16686/api/traces?service=ts-assurance-service | jq > traces/trace-ts-assurance-service.json 
echo "Tracce servizio ts-assurance-service salvate"

#ts-seat-service
curl -s http://localhost:16686/api/traces?service=ts-seat-service | jq > traces/trace-ts-seat-service.json 
echo "Tracce servizio ts-seat-service salvate"

#ts-travel-plan-service
curl -s http://localhost:16686/api/traces?service=ts-travel-plan-service | jq > traces/trace-ts-travel-plan-service.json 
echo "Tracce servizio ts-travel-plan-service salvate"

#ts-ticket-office-service
curl -s http://localhost:16686/api/traces?service=ts-ticket-office-service | jq > traces/trace-ts-ticket-office-service.json 
echo "Tracce servizio ts-ticket-office-service salvate"

#ts-news-service
curl -s http://localhost:16686/api/traces?service=ts-news-service | jq > traces/trace-ts-news-service.json 
echo "Tracce servizio ts-news-service salvate"

#ts-voucher-service
curl -s http://localhost:16686/api/traces?service=ts-voucher-service | jq > traces/trace-ts-voucher-service.json 
echo "Tracce servizio ts-voucher-service salvate"

#ts-food-map-service
curl -s http://localhost:16686/api/traces?service=ts-food-map-service | jq > traces/trace-ts-food-map-service.json 
echo "Tracce servizio ts-food-map-service salvate"

#ts-route-plan-service
curl -s http://localhost:16686/api/traces?service=ts-route-plan-service | jq > traces/trace-ts-route-plan-service.json 
echo "Tracce servizio ts-route-plan-service salvate"

#ts-food-service
curl -s http://localhost:16686/api/traces?service=ts-food-service | jq > traces/trace-ts-food-service.json 
echo "Tracce servizio ts-food-service salvate"

#ts-consign-service
curl -s http://localhost:16686/api/traces?service=ts-consign-service | jq > traces/trace-ts-consign-service.json 
echo "Tracce servizio ts-consign-service salvate"

#ts-consign-price-service
curl -s http://localhost:16686/api/traces?service=ts-consign-price-service | jq > traces/trace-ts-consign-price-service.json 
echo "Tracce servizio ts-consign-price-service salvate"

#ts-admin-basic-info-service
curl -s http://localhost:16686/api/traces?service=ts-admin-basic-info-service | jq > traces/trace-ts-admin-basic-info-service.json 
echo "Tracce servizio ts-admin-basic-info-service salvate"

#ts-admin-order-service
curl -s http://localhost:16686/api/traces?service=ts-admin-order-service | jq > traces/trace-ts-admin-order-service.json 
echo "Tracce servizio ts-admin-order-service salvate"

#ts-admin-route-service
curl -s http://localhost:16686/api/traces?service=ts-admin-route-service | jq > traces/trace-ts-admin-route-service.json 
echo "Tracce servizio ts-admin-route-service salvate"

#ts-admin-travel-service
curl -s http://localhost:16686/api/traces?service=ts-admin-travel-service | jq > traces/trace-ts-admin-travel-service.json 
echo "Tracce servizio ts-admin-travel-service salvate"

#ts-admin-user-service
curl -s http://localhost:16686/api/traces?service=ts-admin-user-service | jq > traces/trace-ts-admin-user-service.json 
echo "Tracce servizio ts-admin-user-service salvate"

#jaeger
curl -s http://localhost:16686/api/traces?service=jaeger | jq > traces/trace-jaeger.json 
echo "Tracce servizio jaeger salvate"




































































