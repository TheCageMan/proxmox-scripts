#!/bin/bash

for container in $(lxc-ls -1 --running); do
  error=0

  echo
  echo
  echo "======================="
  echo "updating " $container
  echo "======================="

  OS="`cat /etc/pve/lxc/$container.conf | grep ostype | awk '{ print $2 }'`"

  if [[ "$OS" == "alpine" ]]
  then
    (lxc-attach -n "$container" -- /bin/sh -c "apk update && apk upgrade") || error=1
  elif [[ "$OS" == "debian" ]]
  then
    (lxc-attach -n "$container" -- /bin/bash -c "apt update && apt -y upgrade") || error=1
  fi

  if [ $error -eq 1 ]
  then
    errors="${errors}Error upgrading container $container\n"
  fi
done

if [ ! -z "$errors" ]
then
  echo -e "problems upgrading containers on host `hostname -f`: \n $errors" | mail -s "Upgrade report host `hostname -f`" -a "From: root" "root"
else
  echo -e "containers on host `hostname -f` upgraded succuessfully" | mail -s "Upgrade report host `hostname -f`" -a "From: root" "root"
fi

echo
echo
echo "======================="
echo "Script done."
echo "======================="
