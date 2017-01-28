#!/bin/bash

#Cache the credential so we don't need to input the password for each git pull
git config --global credential.helper cache

if [ $# -eq 0 ]
then
    echo 
    echo "usage: $0 branch workspace [filter]"
    echo
    echo "branch:    the branch to be stated"
    echo "workspace: the dirctory to put the git repos"
    echo "filter:    filter for the author, like a email domain" 
    echo
    echo "This tool will generate a commit number report by author."
    echo "This tool looks for the git repos in the git-repos.txt under the current working directory."
    echo "The git repos will be downloaded to the workspace dirctory in the input parameter."
    echo
    exit 1
fi


branch=$1
workspace=$2
git_repo_list=`pwd`/git-repos.txt
stat_result=`pwd`/stat-result-$branch-`date +%Y%m%d%H%M%S%N`.txt

if [ -n "$3" ];
then
    filter=$3
fi  

echo $stat_result
if [ ! -d  $workspace ]
then
    mkdir $workspace 
fi

cd $workspace
echo "stat date: "`date`>$stat_result

while read line
do
   echo "stat repo: "$line
   if [ ! -d $line ]
   then
       git clone https://gerrit.open-o.org/r/$line
       git checkout $branch
   else
       cd $line 
       git checkout $branch
       git pull 
       cd .. 
   fi 

   cd $line 
   echo $line >> $stat_result
   
   if [ -n $filter ] ;
   then
       git shortlog HEAD -s -n -e|grep $filter >> $stat_result
   else
       git shortlog HEAD -s -n -e >> $stat_result
   fi
   cd .. 
done < $git_repo_list 

more $stat_result

