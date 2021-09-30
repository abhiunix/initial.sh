#!/usr/bin/env bash

format_time() {
  ((h=${1}/3600))
  ((m=(${1}%3600)/60))
  ((s=${1}%60))
  printf "%02d:%02d:%02d\n" $h $m $s
 }

filename=$0
parentDomain=$1

echo "
      =||=  :;\    |: |; ==========  |;     /\      ||              ____        
       ||   :; \   |: |;     ||      |;    /  \     ||             / ___|  ||   ||
       ||   :;  \  |: |;     ||      |;   /====\    ||             \___ \  ||___||
       ||   :;   \ |: |;     ||      |;  /      \   ||              ___) | ||   ||
      =||=  :;    \|: |;     ||      |; /        \  [[=====]]  (*) |____/  ||   ||

"

time=$(date '+%D %X'); echo -e "\033[31mScript Started at\033[m" $time 

function function1(){
  echo -e "\033[31mStarting initial phase\033[m" | notify --silent
  echo -e "\033[31m\033[m" | notify --silent
  echo -e "\033[31m~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~>\033[m" | notify --silent

  echo -e "\033[31mStarting subdomain enumeration with assetfinder:\033[m"
  assetfinder $parentDomain >> domains
  echo -e "\033[31mDone with assetfinder. File saved to domains\033[m"
  echo -e "\033[31m\033[m"
  echo -e "\033[31m~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~>\033[m"

  echo -e "\033[31mStarting subdomain enumeration with subfinder:\033[m"
  subfinder -silent -d $parentDomain >> domains
  echo -e "\033[31mDone with subfinder. File saved/appended to domains\033[m"
  echo -e "\033[31m\033[m"
  echo -e "\033[31m~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~>\033[m"

  echo -e "\033[31mStarting subdomain enumeration with findomain:\033[m"
  findomain -q -t $parentDomain >> domains
  echo -e "\033[31mDone with findomain. File saved/appended to domains\033[m"
  echo -e "\033[31m\033[m"
  echo -e "\033[31m~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~>\033[m"

  echo -e "\033[31mStarting subdomain enumeration with crtsh:\033[m"
  crtsh $parentDomain >> domains
  echo -e "\033[31mDone with crtsh. File saved/appended to domains\033[m"
  echo -e "\033[31m~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~>\033[m"
  echo -e "\033[31m\033[m"

  echo -e "\033[31mSorting..\033[m"
  cat domains | sort | uniq > uniq.domains
  echo -e "\033[31mFile saved to uniq.domains.\033[m" 
  echo -e "\033[31m~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~>\033[m"
  echo -e "\033[31m \033[m"
}

function function2(){
  echo -e "\033[31mStarting httprobe on uniq.domains \033[m"
  cat uniq.domains | httprobe -p http:81 -p http:3000 -p https:3000 -p http:3001 -p https:3001 -p http:8000 -p http:8080 -p https:8443 -p https:10000 -p http:9000 -p https:9443 -c 50 | tee hosts
  echo -e "\033[31mDone with httprobe. File saved to hosts\033[m"
  echo -e "\033[31m~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~>\033[m"
  echo -e "\033[31m\033[m"
}

function function3(){
  echo -e "\033[31m\033[m"
  echo -e "\033[31mStarting httpx on hosts. Enumerating title and status-code.. \033[m"
  cat hosts | httpx -title -status-code -threads 250 -follow-redirects -o hosts.titled
  echo -e "\033[31mDone with httpx. File saved to host.titled\033[m"
  echo -e "\033[31m~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~>\033[m"
  echo -e "\033[31m\033[m"
}

function function4(){
  echo -e "\033[31m\033[m"
  echo -e "\033[31mCreating a domain list containg all titled domains.. with status code 200.\033[m"
  cat hosts.titled | grep 200 | awk '{print $1}' > hosts.titled.200
  echo -e "\033[31mAll hosts which contains titles have been saved to hosts.titled.200\033[m"
  echo -e "\033[31m~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~>\033[m"
  echo -e "\033[31m\033[m"
}

function function5(){
  #cat titledDomain | xargs -I{} ffuf -c -w ~/tools/SecLists/myall.txt -u {}/FUZZ -t 150
  echo -e "\033[31m\033[m"
  echo -e "\033[31mStarting dirsearch on hosts.titled.200 to find sensitive files with default dictionary..\033[m"
  python3 ~/tools/dirsearch/dirsearch.py -l ./hosts.titled.200 * -t 50 | tee hosts.titled.200.dirsearch-default
  echo -e "\033[31mdirsearch logs(with default dictionary) are saved to dirsearch.default\033[m"
  echo -e "\033[31m~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~>\033[m"
  echo -e "\033[31m\033[m"
}

function function6(){
  echo -e "\033[31m\033[m"
  echo -e "\033[31mStarting dirsearch on hosts.titled.200 to find sensitive files with myall.txt dictionary..\033[m"
  python3 ~/tools/dirsearch/dirsearch.py -l ./hosts.titled.200 -w ~/tools/SecLists/myall.txt * -t 90 | tee hosts.titled.200.dirsearch-custom
  echo -e "\033[31mdirsearch logs(with default dictionary) are saved to hosts.titled.200.dirsearch-custom\033[m"
  echo -e "\033[31m~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~>\033[m"
  echo -e "\033[31m\033[m"
}

  #[This megOut file you have to analyze it manually.]
function function7(){
  echo -e "\033[31m \033[m"
  echo -e "\033[31mStarting meg on hosts\033[m"
  meg -d 1000 -v / ./hosts megOutput
  echo -e "\033[31mOutput of meg are saved to out/\033[m"
  echo -e "\033[31m~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~>\033[m"
  echo -e "\033[31m\033[m"
}

function function8(){
  echo -e "\033[31m \033[m"
  echo -e "\033[31mStarting gau on hosts.titled.200\033[m"
  cat hosts.titled.200 | gau -b jpg,png,gif,jpeg,mp3 | tee hosts.titled.200.gau
  echo -e "\033[31mFiltering URLs  gau on hosts.titled.200\033[m"
  cat hosts.titled.200.gau | uro | tee hosts.titled.200.gau.uro
  echo -e "\033[31mOutput of gau are saved to hosts.titled.200.gau.uro\033[m"
  echo -e "\033[31m~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~>\033[m"
  echo -e "\033[31m\033[m"
}

# If the hosts.titled.200.gau.uro file is too large then this could help to split the task.
# sed '1940740,2500000!d' hosts.titled.200.gau.uro | httpx -status-code -threads 250 | tee hosts.titled.200.gau.uro.httpx2
function function9(){
  echo -e "\033[31m \033[m"
  echo -e "\033[31mStarting httpx on hosts.titled.200.gau.uro\033[m"
  cat hosts.titled.200.gau.uro | httpx -status-code -threads 250 | tee hosts.titled.200.gau.uro.httpx
  echo -e "\033[31mOutput of httpx are saved to hosts.titled.200.gau.uro.httpx\033[m"
  echo -e "\033[31m~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~>\033[m"
  echo -e "\033[31m\033[m"
}

function function10(){   
  echo -e "\033[31m \033[m"
  echo -e "\033[31mStarting filter for 200 on hosts.titled.200.gau.uro.httpx\033[m"
  if [ -e ./hosts.titled.200.gau.uro.httpx ]; 
   then 
  cat hosts.titled.200.gau.uro.httpx | grep 200 | awk '{print $1}' > hosts.titled.200.gau.uro.httpx.200
  echo -e "\033[31mOutput of filters are saved to hosts.titled.200.gau.uro.httpx.200\033[m"
  echo -e "\033[31m~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~>\033[m"
  echo -e "\033[31m\033[m"
   else 
  echo "The hosts.titled.200.gau.uro.httpx file doesn't exists" 
  fi 

}

function function11(){
  echo -e "\033[31m ============GitHub-Recon===========\033[m"
  echo -e "\033[31mStarting Gitrob on $parentDomain. \033[m"  
  gitrob $parentDomain | tee $parentDomain.gitrob
  echo -e "\033[31mFile saved to $parentDomain.gitrob\033[m"
}

function function12(){
  echo "We are in function11."
}

function function13(){
  echo "We are in function11."
}

function loops(){
  for i in `seq $in1 $in2`;do
    case $i in
      1 ) echo "You have choosen function1."
        function1
        echo "function1 completed"
        ;;
      2 ) echo "You have choosen function2."
        function2
        echo "function2 completed"
        ;;
      3 ) echo "You have choosen function3."
        function3
        echo "function3 completed"
        ;;
      4 ) echo "You have choosen function4."
        function4
        echo "function4 completed"
        ;;
      5 ) echo "You have choosen function5."
        function5
        echo "function5 completed"
        ;;
      6 ) echo "You have choosen function6."
        function6
        echo "function6 completed"
        ;;
      7 ) echo "You have choosen function7."
        function7
        echo "function7 completed"
        ;;
      8 ) echo "You have choosen function8."
        function8
        echo "function8 completed"
        ;;
      9 ) echo "You have choosen function9."
        function9
        echo "function9 completed"
        ;;
      10 ) echo "You have choosen function10."
        function10
        echo "function10 completed"
        ;;
      11 ) echo "You have choosen function11."
        function11
        echo "function11 completed"
        ;;
      12 ) echo "You have choosen function12."
        function12
        echo "function12 completed"
        ;;
      13 ) echo "You have choosen function13."
        function13
        echo "function13 completed"
        ;;   
      * ) echo "o_O Are you a robot?"
    esac
  done
}

function main(){
echo "Start the initial phase of recon" ;
echo "Choose an Option, either single arg or a range. eg: initial.sh 3 or initial.sh 1 3" ;
echo "1 - Find all domains and subdomains. Saved to domains, uniq.domains" ;
echo "2 - Start httprobe on uniq.domains. Saved to hosts" ;
echo "3 - Start httpx on hosts. Enumerating title and status-code. Saved to host.titled" ;
echo "4 - Creating a domain list containg all titled domains with status code 200. Saved to hosts.titled.200" ;
echo "5 - Starting dirsearch on hosts.titled.200 to find sensitive files with default dictionary. Saved to hosts.titled.200.dirsearch-default";
echo "6 - Starting dirsearch on hosts.titled.200 to find sensitive files with myall.txt dictionary. Saved to hosts.titled.200.dirsearch-custom";
echo "7 - Starting meg on hosts. saved to out/";
echo "8 - Starting gau on hosts.titled.200. saved to hosts.titled.200.gau.uro";
echo "9 - Starting httpx on hosts.titled.200.gau.uro. hosts.titled.200.gau.uro.httpx";
echo "10 - Starting filter for 200 on hosts.titled.200.gau.uro.httpx. hosts.titled.200.gau.uro.httpx.200";
echo "11 - Stat github recon with gitrob. File saved to $parentDomain.gitrob";
echo "12 - Use Delfox to to search for XSS, SQLi or any other injection points. Output saved to delfox";
echo "13 - Not yet implemented";

lastIn1=0
lastIn2=0

echo "Warning: Last time you have entered $lastIn1 $lastIn2"
read -p "Choose range1 : " in1
sed -i .bak -r "s/^(lastIn1=).*/\1$in1/"  $filename

read -p "Choose range2 : " in2
sed -i .bak -r "s/^(lastIn2=).*/\1$in2/"  $filename

loops
echo "Script completed in $(format_time $SECONDS)"
}

if (( $# < 2 )); then
  main
     exit  
fi


# time to Finish the job:
echo "Script completed in $(format_time $SECONDS)"


# check if the previous directory present.