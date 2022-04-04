#!/bin/bash

if [ $1 == "help" ]; then
  echo "Usage: create_user {usersString} ((adminLogin)) ((adminPwd))"
  echo "'adminLogin' and 'adminPwd' are optional. They are required when user creation requires authentification."
  echo "usersString should be built as such: {userName}:{userPwd}:{db1}={role}/{db2}={role}"
  echo "Example: johnny:bgoode:guitar=readWrite/neworleans=readWrite"
fi

loginParams=
if [ ! -z $2 ] && [ ! -z $3 ]; then
  loginParams="-u $2 -p $3"
fi

exists(){
  if [ "$2" != in ]; then
    echo "[ERR ] Incorrect usage."
    echo "[ERR ] Correct usage: exists {key} in {array}"
    return
  fi   
  eval '[ ${'$3'[$1]+muahaha} ]'  
}

IFS=":" read -a arr <<< $1

if ! exists "0" in arr || [ -z ${arr[0]} ]; then
  echo "[ERR ] Username must be provided as first segment of the parameter string."
  echo "[ERR ] Example: user1:pwd1:db1=readWrite"
  exit 1
fi
user=${arr[0]}
echo "[INFO] Executing 'create_user' with user '$user'"

if ! exists "1" in arr || [ -z ${arr[1]} ]; then
  echo "[ERR ] No password provided."
  echo "[ERR ] Example: user1:pwd1:db1=readWrite"
  exit 1
fi
password=${arr[1]}

if ! exists "2" in arr || [ -z ${arr[2]} ]; then
  echo "[ERR ] User roles required."
  echo "[ERR ] Example: user1:pwd1:db1=readWrite"
  exit 1
fi
rolesArrSection=${arr[2]}

if [ $password == "@" ]; then
  echo "[WAIT] Please provide password:"
  read -s password
fi

IFS="/" read -a rolesArr <<< $rolesArrSection

jsCmdRolesPart=
for roles in "${rolesArr[@]}"
do
  IFS="=" read -a role <<< $roles
  if ! exists "0" in role || ! exists "1" in role; then
    echo "[WARN] 'db' or 'role' not properly specified."
    echo "[WARN] Example: user1:pwd1:db1=readWrite"
    continue
  fi
  db=${role[0]}
  r=${role[1]}
  if [ ! -z $jsCmdRolesPart ]; then
    jsCmdRolesPart="$jsCmdRolesPart,"
  fi
  jsCmdRolesPart="$jsCmdRolesPart{role:\"$r\",db:\"$db\"}"
done

createUserParam="{user:\"$user\",pwd:\"$password\",roles:[$jsCmdRolesPart]}"
mongo $loginParams --eval "db.getSiblingDB('admin').createUser($createUserParam)"