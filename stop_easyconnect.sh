#!/bin/sh
function killprocess()
{
    processname=$1
    echo "kill process "$processname
	killall $processname
    proxypids=$(ps aux | grep -v grep | grep $processname | awk '{print $2}')
    for proxypid in $proxypids
    do
        echo "find process id send kill -9 "$proxypid
        kill -9 $proxypid
    done
}

unlink /tmp/stop_easyconnect.log
exec &> /tmp/stop_easyconnect.log 2>&1

username=`stat -f %Su /dev/console`
sudo -u $username launchctl unload /Library/LaunchAgents/com.sangfor.ECAgentProxy.plist
loginusers=`ps aux | grep -v grep | grep loginwindow | awk '{print $1}'`
for loginuser in $loginusers
do
    echo "deal ECAgentProxy of "$loginuser
    contextpid=$(ps -axj | grep loginwindow | awk "/^$loginuser / {print \$2;exit}")
    if [[ -z "$contextpid" ]]; then
        continue
    fi
    launchctl bsexec $contextpid sudo -u $loginuser launchctl unload /Library/LaunchAgents/com.sangfor.ECAgentProxy.plist
done

killprocess ECAgent
killprocess svpnservice
killprocess CSClient
killprocess ECAgentProxy
killprocess /Applications/EasyConnect.app/Contents/MacOS/EasyConnect

launchctl unload /Library/LaunchDaemons/com.sangfor.EasyMonitor.plist
