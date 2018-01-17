#!/bin/bash
echo "Starting services as background processes..."
cd /opt/ewdjs
sudo nohup node startFederator > /var/log/ewd/federatorCPM.log 2>&1 &
sudo nohup node ewdStart-pseudovet > /var/log/ewd/ewdjsCPM.log 2>&1 &

