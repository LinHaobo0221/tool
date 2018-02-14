#!/bin/sh

#共通環境変数読み込み
CURRENT=/home
. $CURRENT/COMMON.sh

# ファイル格納場所定義

FILEILIST="$(cat $LOADER_LST)";

LOADER_LOGS='loader_logs'

for fileObj in ${FILEILIST[@]}
  
do
  
  OLDIFS=$IFS
  
  IFS=','
  
  fileInfoArrays=($fileObj)
  
  ctlFile=$CTL/${fileInfoArrays[0]}
  
  dataFile=$INPUT_FILE/${fileInfoArrays[1]}
  
  badFileName=${fileInfoArrays[2]}
  
  logFileName=${fileInfoArrays[3]}
  
  IFS=$OLDIFS
  
  logsFolder=$LOGS/$LOADER_LOGS
  
  mkdir -p $logsFolder
  
  chmod 775 -R $logsFolder
  
  logFile=$logsFolder/$logFileName
  
  badFile=$logsFolder/$badFileName
  
  sqlldr userid=$DB_USER/$DB_PASS control=$ctlFile data=$dataFile bad=$badFile log=$logFile direct=true rows=10000
  
done;

