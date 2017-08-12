# ghsuk
Bash script to provision SSH `~/.ssh/authorized_keys` file of a OS user from GitHub. 

## background
> When working in big organization as sysadmin or devop you many have to manage access to servers for developers. These days SSH access to an application servers is kind of a standard. Moreover if you don't want to maintain passwords with a complicated rotation and complexity policy, well public / private ssh keys are the best you can get. _Sadly no every application can use ssh key pairs._

## the script
> The script "github-ssh-public-keys.sh" will connect to GitHub and list all users for an Organization, then for each user will get identifying information and its public ssh key. Then write all this in the `~/.ssh/authorized_keys`. Et voila, developer will ave access as `$USER@$SERVER`. You can set a cron job to keep this access up to days.

## improvements
> One can create user per project and get keys per project so that not all developers from an organization access all projects

## example
> depending on the number of users this will run for 1-2 minutes
```sh
$> ./github-ssh-public-keys.sh 
enter organization name: e.g. [ec-europa] ec-europa
enter Github username: e.g. [ivan-davidkov] ivan-davidkov
enter Github user's password: e.g. [4c82-9e70-96eb7ca2c1db] 4c82-9e70-96eb7ca2c1db
```

## result
> after it is over it will result in something like this
```sh
$> cat .ssh/authorized_keys
#- "Name:null - Login:ivan-davidkov - ID:12543939 - Email:null - Blog:" Login:ivan-davidkov_ID:12543939 -#
ssh-rsa AA3NzaC1yc2EAAAABIwAAAQEAs6xjf7rCbGGsV69+dNbXyai9m8g/8uAnjV3Kh0FxgmJXDoYWVD/7AR28CYCZRmpYhahQCCbkuTb5TBcvW20BVmhVL1I/+cI/h+veqDcP/LM6ZdzIGz4ViG+DXsi5vweyIDGnjBADSEG7uFc0JjYaf4BQ8gSYNwz6gfmBmsSSFBD2HaYEZ62miZh5/Qdyc3MyVGJ5bcKek+B/HQ0VsIcNCdcX1EkoiFye28zS7rRTugbXm/I99yrMD+CKaSBMbFrd+KAIHpAEy17ag3WSoGFrdB3oYhv6S99HpczVyP2Q5ttT9Z67L/6EozPdkLIIocjkXvlUO2hVEMCf7etjzGApPQ== Login:ivan-davidkov_ID:12543939
```

## one-liner
> One can export the 3 variables are global and run the script as one-liner
```sh
export GITHUB_ORGANIZATION=ec-europa && export GITHUB_USER=ivan-davidkov && export GITHUB_PASS=4c82-9e70-96eb7ca2c1db && for p in `seq 1 ${num_pages}`; do curl -s -u "${github_user}:${github_pass}" "https://api.github.com/orgs/${github_org}/members?page=$p&per_page=100" | jq -r '.[] | "\(.url) Login:\(.login)_ID:\(.id)"' | while read url comment; do echo -en "#- `curl -s -u "${github_user}:${github_pass}"  "${url//}" | jq '"Name:\(.name) - Login:\(.login) - ID:\(.id) - Email:\(.email) - Blog:\(.blog)"'` $comment -#\n`curl -s -u "${github_user}:${github_pass}"  "$url/keys"| jq -r .[0].key`" >> ${HOME}/.ssh/authorized_keys && echo -e " $comment \n" >> ${HOME}/.ssh/authorized_keys ; done ; done 
```
