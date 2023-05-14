#!/usr/bin/env bash
# Directadmin Monitoring
## Settings
discord="URL"
HOSTNAME=`hostname`

# Check if there is enough available disk space
total_space=$(df -H | awk '{if($NF=="/") print $2}' | tr -d 'G')
free_space=$(df -H | awk '{if($NF=="/") print $4}' | tr -d 'G')
required_space=1
if (( $(echo "$free_space < $required_space" | bc -l) )); then
    echo "Error: Not enough disk space. Available space: ${free_space}G, Required space: ${required_space}G"
BACKUP_ERROR='{"content": "Alert for: '${HOSTNAME}', Error: Not enough disk space. Available space: '${free_space}' GB which is less than: '${required_space}' GB "}'
curl -H "Content-Type: application/json" -X POST -d "$BACKUP_ERROR" "$discord"    
wait $!
fi

# Check if there is enough free RAM
free_ram=$(free -m | awk '/^Mem/ {print $4}')
if (( $free_ram < 1024 )); then
    echo "Error: Not enough free RAM. Available RAM: ${free_ram}MB, Required RAM: 1024MB"
    RAM_ALERT='{"content": "Alert for: '${HOSTNAME}', Error: Not enough free RAM. Available RAM: '${free_ram}' MB"}'
curl -H "Content-Type: application/json" -X POST -d "$RAM_ALERT" "$discord"    
wait $!
fi


# Check if there is no large Exim Mail Queue
mail_queue=$(exim -bpc)
if (( $mail_queue > 50 )); then
    echo "Error: Large mail queue. Email in the mail queue: ${mail_queue}"
    QUEUE_ALERT='{"content": "Alert for: '${HOSTNAME}', Error: Large mail queue. Email in the mail queue: '${mail_queue}' "}'
curl -H "Content-Type: application/json" -X POST -d "$QUEUE_ALERT" "$discord"    
wait $!
fi

