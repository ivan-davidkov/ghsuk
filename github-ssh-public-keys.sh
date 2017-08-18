#!/bin/bash 
#title           :github-ssh-public-keys.sh
#description     :This script will download user(s) public ssh key from GitHub
#author		 :Ivan Davidkov <ivan@davidkov.eu>
#date            :10082017
#version         :0.1
#usage		 :./github-ssh-public-keys.sh 
#notes           :tools curl, jq and are used in this this script.
#notes           :GitHub API v3 https://developer.github.com/v3/
#notes           :JQ https://stedolan.github.io/jq/
#bash_version    :4.2.46(1)-release
#jq_version      :jq-1.5
#curl_version    :curl 7.51.0 (x86_64-redhat-linux-gnu) libcurl/7.51.0 NSS/3.21.3 Basic ECC zlib/1.2.8 libidn2/0.16 libpsl/0.6.2 (+libicu/50.1.2) libssh2/1.4.2 - Protocols: dict file ftp ftps gopher http https imap imaps ldap ldaps pop3 pop3s rtsp scp sftp smb smbs smtp smtps telnet tftpi - Features: AsynchDNS IDN IPv6 Largefile GSS-API Kerberos SPNEGO NTLM NTLM_WB SSL libz UnixSockets PSL 

################
# requirements #
################

#check for curl
if ! [ -x "$(command -v curl)" ]; then
  echo 'Error: curl is not installed.' >&2
  echo 'Tip: please install curl [e.g. sudo yum install curl]' >&2
  exit 1
fi

#check for jq
if ! [ -x "$(command -v jq)" ]; then
  echo 'Error: jq is not installed.' >&2
  echo 'Tip: please install jq [e.g. sudo yum install jq]' >&2
  exit 1
fi

#check for ${HOME}/.ssh/authorized_keys
if ! [ -f ${HOME}/.ssh/authorized_keys ]; then
  echo 'Error: ${HOME}/.ssh/authorized_keys not found.' >&2
  echo 'Tip: please create ${HOME}/.ssh/authorized_keys and set proper permission' >&2
  exit 1
fi

#############
# variables #
#############

#organization name 
if ! [ -z ${GITHUB_ORGANIZATION} ] ; then 
  github_org="${GITHUB_ORGANIZATION}"
else
  read -p "enter organization name: e.g. [ec-europa] " github_org
fi

#valid user
if ! [ -z ${GITHUB_USER} ] ; then
  github_user="${GITHUB_USER}"
else
  read -p "enter Github username: e.g. [ivan-davidkov] " github_user
fi

#the above user password
if ! [ -z ${GITHUB_PASS} ] ; then
  github_pass="${GITHUB_PASS}"
else
  read -p "enter Github user's password: e.g. [4c82-9e70-96eb7ca2c1db] " github_pass
fi

#number of pages to browse
#default results set to 100
#2 pages times 100 results = 200 users, increment this value for more users
num_pages=2


#the following one line will get all users in your organization
#then for each user will download its public ssh key and some other info
#you can change to what you think is needed for your configuration
# !WARNING! you run this script github account(s) will have access on this Server
# !WARNING! you run this script github account(s) will have access on this Server
# !WARNING! you run this script github account(s) will have access on this Server
for p in `seq 1 ${num_pages}`; do curl -s -u "${github_user}:${github_pass}" "https://api.github.com/orgs/${github_org}/members?page=$p&per_page=100" | jq -r '.[] | "\(.url) Login:\(.login)_ID:\(.id)"' | while read url comment; do echo -en "# `curl -s -u "${github_user}:${github_pass}" "${url//}" | jq '"Name:\(.name) - Login:\(.login) - ID:\(.id) - Email:\(.email) - Blog:\(.blog)"'` -- \"Repositories list | `echo -n $(curl -s -u "${github_user}:${github_pass}" "$url/repos" | jq -r '.[] | "\(.name)"')` \"#\n`curl -s -u "${github_user}:${github_pass}"  "$url/keys"| jq -r .[].key`" >> ${HOME}/.ssh/authorized_keys && echo -e " $comment \n" >> ${HOME}/.ssh/authorized_keys ; done ; done


#e.g. of a line in my .ssh/authorized_keys
##########################################################
#- "Name:null - Login:ivan-davidkov - ID:12543939 - Email:null - Blog:" Login:ivan-davidkov_ID:12543939 -#
#ssh-rsa AA3NzaC1yc2EAAAABIwAAAQEAs6xjf7rCbGGsV69+dNbXyai9m8g/8uAnjV3Kh0FxgmJXDoYWVD/7AR28CYCZRmpYhahQCCbkuTb5TBcvW20BVmhVL1I/+cI/h+veqDcP/LM6ZdzIGz4ViG+DXsi5vweyIDGnjBADSEG7uFc0JjYaf4BQ8gSYNwz6gfmBmsSSFBD2HaYEZ62miZh5/Qdyc3MyVGJ5bcKek+B/HQ0VsIcNCdcX1EkoiFye28zS7rRTugbXm/I99yrMD+CKaSBMbFrd+KAIHpAEy17ag3WSoGFrdB3oYhv6S99HpczVyP2Q5ttT9Z67L/6EozPdkLIIocjkXvlUO2hVEMCf7etjzGApPQ== Login:ivan-davidkov_ID:12543939 
##########################################################

