curl запрос из метрики
# HELP promhttp_metric_handler_requests_total Total number of scrapes by HTTP status code.
# Кол-во сообщений по коду 503
output503='/home/sa0001wps/scripts/logs_counter/outputs/FCM/output503'
FCM=$(curl -s mts1wps1:9253/metrics | grep "promhttp_metric_handler_requests_total{code=\"503\"}" | cut -d \  -f 2 )
echo $FCM > $output503

тейл по таймауту 
#variables section
today=`date +%Y-%m-%d`
parsingTime='30s'
outputDirectory='/home/sa0001wps/scripts/logs_counter/outputs'

#firebaseclient
firebaseclientLogPath='/opt/wps/firebaseclient/logs'
firebaseclientOutputDirectory=$outputDirectory'/firebaseclient'
firebaseclientOutput=$firebaseclientOutputDirectory'/firebaseclientOutput'
firebaseclientCounter=`timeout --foreground $parsingTime tail -n 0 -f $firebaseclientLogPath/FCMSender_$today.log | wc -l`
echo $firebaseclientCounter > $firebaseclientOutput

#if the output directory doesn't exist, to create it
[[ -d $firebaseclientOutput ]] || mkdir -p $firebaseclientOutput

#firebaseclientFromRedis
firebaseclientFromRedis=`timeout --foreground $parsingTime tail -n 0 -f $firebaseclientLogPath/FCMSender_$today.log | grep 'FROM REDIS' | wc -l`
firebaseclientFromRedisOutput=$firebaseclientOutputDirectory'/firebaseclientFromRedisOutput'
echo $firebaseclientFromRedis > $firebaseclientFromRedisOutput 

crontab -e (на 5 минут)
#MonitorRestin
*/5 * * * * /home/sa0001wps/scripts/restin.sh

пример архивации логов и удаление старше 2 дней
#!/bin/bash

yesterday=`date -d yesterday +"%Y-%m-%d"`

#WPS logs
gzip /opt/wps/cerebro/logs/$yesterday.log
gzip /opt/wps/firebaseclient/logs/FCMSender_$yesterday.log
gzip /opt/wps/messagesAPI/logs/messagesAPI_$yesterday.log
gzip /opt/wps/restin/logs/restAPP_$yesterday.log

#System logs
gzip /var/log/*-`date -d yesterday +"%Y%m%d"`
rm -rf /var/log/*-`date --date="2 days ago" +%Y%m%d`
