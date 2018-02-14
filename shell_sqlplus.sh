#!/bin/sh

#shell run sqlplus and create log file 
#in the end change file encoding from utf-8 to cp932

#共通環境変数読み込み
CURRENT=/home
. $CURRENT/COMMON.sh

FILES=`cat $PROC_LST  | grep $1`;

PROC_LOGS='proc_logs'
  
  for file in ${FILES[@]}
  
do
  
  OLDIFS=$IFS
  
  IFS=','
  
  fileInfoArrays=($file)
  
  IFS=$OLDIFS
  
  sourceFile=$SQL/${fileInfoArrays[0]}
  
  logsFolder=$LOGS/$PROC_LOGS
  
  mkdir -p $logsFolder
  
  chmod 775 -R $logsFolder
  
  logFile=$logsFolder/${fileInfoArrays[1]}
  
  tmperrFile=$CURRENT/${fileInfoArrays[3]}
  
  sqlplus $DB_USER/$DB_PASS@dev03 <<EOF> $logFile
  
  @$sourceFile >> $logFile
  
EOF

  tmperrFile=$CURRENT/${fileInfoArrays[2]}
  errFile=$CURRENT/${fileInfoArrays[3]}
  
  tmprstFile=$CURRENT/${fileInfoArrays[4]}
  rstFile=$CURRENT/${fileInfoArrays[5]}
  
  
  mv $errFile $tmperrFile
  mv $rstFile $tmprstFile
  
  iconv -f UTF-8 -t CP932 $tmperrFile | sed $'s/$/\r/' > $errFile
  iconv -f UTF-8 -t CP932 $tmprstFile | sed $'s/$/\r/' > $rstFile
  
  rm -f $tmperrFile
  rm -f $tmprstFile

done;

exit 0

