#!/bin/bash
# Paths
LOGFILE="/var/log/auth.log"
STATEFILE="/var/log/ssh-auth.offset"
OUTPUT="/var/log/ssh-auth.json"

# Read last offset (or 0 if state file doesn’t exist)
if [[ -f "$STATEFILE" ]]; then
  last_offset=$(<"$STATEFILE")
else
  last_offset=0
fi

# Get current file size
current_size=$(stat --format="%s" "$LOGFILE")

# Reset offset on rotation or truncation
if (( current_size < last_offset )); then
  last_offset=0
fi

# Extract only the new bytes since last offset
tail -c +"$((last_offset + 1))" "$LOGFILE" > /tmp/auth.new

# Parse new entries and output as JSON array
awk 'BEGIN { IGNORECASE=1 }
    /Invalid user/ {
        ts = $1; host = $2; failed_user="unknown"; src="unknown"; msg=""
        for(i=3;i<=NF;i++){
            msg=msg" "$i
            if($i=="Invalid"&&$(i+1)=="user") failed_user=$(i+2)
            if($i=="from") src=$(i+1)
        }
        gsub(/^ /,"",msg)
        if(src!="unknown")
          printf "{\"timestamp\":\"%s\",\"host_name\":\"%s\",\"failed_user\":\"%s\",\"source_ip\":\"%s\",\"message\":\"%s\"}\n",
                 ts,host,failed_user,src,msg
    }
    /Accepted/ {
        ts = $1; host = $2; success_user="unknown"; src="unknown"; msg=""
        for(i=3;i<=NF;i++){
            msg=msg" "$i
            if($i=="for") success_user=$(i+1)
            if($i=="from") src=$(i+1)
        }
        gsub(/^ /,"",msg)
        if(src!="unknown"&&success_user!="unknown")
          printf "{\"timestamp\":\"%s\",\"host_name\":\"%s\",\"success_user\":\"%s\",\"source_ip\":\"%s\",\"message\":\"%s\"}\n",
                 ts,host,success_user,src,msg
    }
' /tmp/auth.new | jq -s '.' > /tmp/auth.new.json

# Merge old and new arrays, then trim to last 50 entries
if [[ -f "$OUTPUT" ]]; then
  jq -s '.[0] + .[1] | if length > 50 then .[length-50:] else . end' \
     "$OUTPUT" /tmp/auth.new.json > /tmp/ssh-auth.updated.json
else
  jq 'if length > 50 then .[length-50:] else . end' /tmp/auth.new.json > /tmp/ssh-auth.updated.json
fi

# Move the updated JSON into the target file
mv /tmp/ssh-auth.updated.json "$OUTPUT"

# Save new offset
echo "$current_size" > "$STATEFILE"
