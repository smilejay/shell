#!/bin/bash
jobs="my-test-job-1 my-test-job-2 my-test-job-3"

user="user"
password="password"
curl="curl --user $user:$password"
curl="curl"
jenkins_url="http://myjenkins.com"
for j in $jobs
do
  disable_url="$curl -o /dev/null --data disable $jenkins_url/job/$j/disable"
  # enable_url="$curl -o /dev/null --data enable $jenkins_url/job/$j/enable"
  echo $disable_url
  $($disable_url)
done
