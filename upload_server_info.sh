#!/bin/bash

# usage
#echo "usage: bash upload_server_info.sh [SERVER_NUM]"

# Define some info
DB_IP="Your DB IP addr"
DB_PORT="Your DB port"
DB_NAME="Your DB name"
DB_USERNAME="Your DB username"
TABLE="server_info"


# SERVER_INFO
if [0];then
  SERVER_INFO=$1
  if [ "$SERVER_INFO" = "" ];then
      echo "Argument is Null"
      exit 1
  fi
fi
SERVER_INFO=`hostname`
echo ---SERVER INFO---
echo SERVER_INFO=$SERVER_INFO

# TIME
TIME=`date "+%Y-%m-%d %H:%M:00"`
echo time=$TIME

# get Memory info
LINE_MEM=`free | grep Mem`
set -f
set -- $LINE_MEM
MEMORY_TOTAL=$2
MEMORY_USED=$3
MEMORY_FREE=$4
echo ---memory---
echo $LINE_MEM
echo memory_total=$MEMORY_TOTAL
echo memory_used=$MEMORY_USED

# get CPU info
# if this command is not running, please install 'sysstat'.
LINE_CPU=`sar 1 1 | tail -1`
set -f
set -- $LINE_CPU
CPU=$3
echo ---cpu---
echo $LINE_CPU
echo cpu_used_rate=$CPU

# get IP addr
IP_ADDR=`ifconfig | grep -A 1 eth0 | tail -1 | cut -d' ' -f11 | cut -d: -f2`
echo $IP_ADDR

# make SQL
<< COMMENTOUT
# Please create table like this
CREATE TABLE server_info
(
  id integer NOT NULL DEFAULT nextval('server_info_id_seq'::regclass),
  "time" timestamp without time zone,
  server_info text,
  cpu_used_percent real,
  memory_total integer,
  memory_used integer,
  ip_addr text,
  CONSTRAINT server_info_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
COMMENTOUT

SQL="INSERT INTO "$TABLE" (time, server_info, cpu_used_percent, memory_total, memory_used, ip_addr) VALUES ('"$TIME"', '"$SERVER_INFO"', "$CPU", "$MEMORY_TOTAL", "$MEMORY_USED", '"$IP_ADDR"');"
echo ---SQL---
echo SQL=$SQL

# make command
# you have to set ~/.pgpass and chmod 600 ~/.pgpass
echo ---COMMAND---
COMMAND="psql -h "$DB_IP" -p $DB_PORT -d $DB_NAME -U $DB_USERNAME -c \"$SQL\""
echo command=$COMMAND

# run command
eval $COMMAND
