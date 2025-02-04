#!/bin/bash
# Logdatei und Ausgabedatei definieren
LOGFILE="/var/log/auth.log"
OUTPUT="/var/log/ssh-auth.json"

awk 'BEGIN { IGNORECASE=1 }
    # Verarbeitung von Zeilen mit "Invalid user"
    /Invalid user/ {
        ts = $1;
        host = $2;
        user = "unknown";
        src = "unknown";
        msg = "";
        for(i = 3; i <= NF; i++){
            msg = msg " " $i;
            if($i == "Invalid" && $(i+1) == "user"){
                user = $(i+2);
            }
            if($i == "from"){
                src = $(i+1);
            }
        }
        gsub(/^ /, "", msg);
        if(src != "unknown")
            printf "{\"timestamp\":\"%s\", \"host_name\":\"%s\", \"user\":\"%s\", \"source_ip_failed\":\"%s\", \"message\":\"%s\"}\n", ts, host, user, src, msg;
    }
    # Verarbeitung von Zeilen mit "Accepted" (z.B. password oder publickey)
    /Accepted/ {
        ts = $1;
        host = $2;
        user = "unknown";
        src = "unknown";
        msg = "";
        for(i = 3; i <= NF; i++){
            msg = msg " " $i;
            if($i == "for"){
                user = $(i+1);
            }
            if($i == "from"){
                src = $(i+1);
            }
        }
        gsub(/^ /, "", msg);
        if(src != "unknown" && user != "unknown")
            printf "{\"timestamp\":\"%s\", \"host_name\":\"%s\", \"user\":\"%s\", \"source_ip_success\":\"%s\", \"message\":\"%s\"}\n", ts, host, user, src, msg;
    }
' "$LOGFILE" | jq -s . > "$OUTPUT"

