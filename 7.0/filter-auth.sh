#!/bin/bash
# Logdatei und Ausgabedatei definieren
LOGFILE="/var/log/auth.log"
OUTPUT="/var/log/ssh-auth.json"

awk 'BEGIN { IGNORECASE=1 }
    # Verarbeitung von Zeilen mit "Invalid user" (fehlgeschlagene Logins)
    /Invalid user/ {
        ts = $1;
        host = $2;
        failed_user = "unknown";
        src = "unknown";
        msg = "";
        for(i = 3; i <= NF; i++){
            msg = msg " " $i;
            if($i == "Invalid" && $(i+1) == "user"){
                failed_user = $(i+2);
            }
            if($i == "from"){
                src = $(i+1);
            }
        }
        gsub(/^ /, "", msg);
        if(src != "unknown")
            printf "{\"timestamp\":\"%s\", \"host_name\":\"%s\", \"failed_user\":\"%s\", \"source_ip\":\"%s\", \"message\":\"%s\"}\n", ts, host, failed_user, src, msg;
    }
    # Verarbeitung von Zeilen mit "Accepted" (erfolgreiche Logins)
    /Accepted/ {
        ts = $1;
        host = $2;
        success_user = "unknown";
        src = "unknown";
        msg = "";
        for(i = 3; i <= NF; i++){
            msg = msg " " $i;
            if($i == "for"){
                success_user = $(i+1);
            }
            if($i == "from"){
                src = $(i+1);
            }
        }
        gsub(/^ /, "", msg);
        if(src != "unknown" && success_user != "unknown")
            printf "{\"timestamp\":\"%s\", \"host_name\":\"%s\", \"success_user\":\"%s\", \"source_ip\":\"%s\", \"message\":\"%s\"}\n", ts, host, success_user, src, msg;
    }
' "$LOGFILE" | jq -s . > "$OUTPUT"
