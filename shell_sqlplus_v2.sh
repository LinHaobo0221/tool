#!/bin/sh

#共通環境変数読み込み
CURRENT=/home/oracle/IKOU
. $CURRENT/00_com/00_config/COMMON.sh

FILES=`cat $PROC_LST  | grep $1`;

PROC_LOGS='proc_logs'
  
for file in ${FILES[@]}
  
do
  
  OLDIFS=$IFS
  
  IFS=','
  
  fileInfoArrays=($file)
  
  IFS=$OLDIFS
  
  sourceFile=$SQL/${fileInfoArrays[0]}
  
  logsFolder=$LOG/$PROC_LOGS
  
  mkdir -p $logsFolder
  
  chmod 775 -R $logsFolder
  
  logFile=$logsFolder/${fileInfoArrays[1]}
  
  fileName=${fileInfoArrays[2]}
  
  sqlplus $DB_USER/$DB_PASS@dev03 <<EOF> $logFile
  
  @$sourceFile $fileName >> $logFile
  
  exit
  
EOF
 
 result_list=`ls $OUTPUT -p | grep -v / | grep ${fileName}`
 
 tempFolder=$OUTPUT/${fileName}_temp
 
 mkdir -p $tempFolder
 
 chmod 775 -R $tempFolder
 
 for result_file in ${result_list[@]}
 
 do
   mv $OUTPUT/$result_file /$tempFolder
 
 done;
 
 transfer_list=`ls $tempFolder`
 
 for transfer_file in ${transfer_list[@]}
 
 do
 
  iconv -f UTF-8 -t CP932 $tempFolder/$transfer_file | sed $'s/$/\r/' > $OUTPUT/$transfer_file
 
 done;

done;

exit 0

