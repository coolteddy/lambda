#!/bin/bash
# Installing Mono on Centos6 box

#Get intanceId
instanceid=`wget -q -O - http://instance-data/latest/meta-data/instance-id`
LOGERR="/home/ec2-user/mono_install_$instanceid.err"
LOGFILE="/home/ec2-user/mono_install_$instanceid.log"

main() {
  install_mono
  create_test_file
  compile_test_file
  run_test_file
  clean_up
}	

log_error(){
  echo "${1}" > $LOGERR
  exit 1
}

log_file() {
  echo "${1}" >> $LOGFILE
}

install_mono() {
  sudo yum install yum-utils -y && log_file "yum install success" \
    || log_error "yum install failed"
  sudo rpm --import "http://keyserver.ubuntu.com/pks/lookup?op=get&search=0x3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF" \
    && log_file "rpm import success" || log_error "rpm import failed"
  sudo yum-config-manager --add-repo http://download.mono-project.com/repo/centos6/ \
    && log_file "yum config success" || log_error "rpm config failed"
  sudo yum install mono-devel && log_file "install mono success" || log_error "install mono failed"
}

create_test_file() {
  cat>/home/ec2-user/hello.cs<<EOF
using System;
 
public class HelloWorld
{
    static public void Main ()
    {
        Console.WriteLine ("Hello Mono");
    }
}
EOF
}

compile_test_file() {
  local RESULT=''
  if [[ -e /home/ec2-user/hello.cs ]]; then
    RESULT=$(mcs /home/ec2-user/hello.cs);
    if [[ $? != 0 ]]; then
      log_error "failed to compile hello.cs:\n${RESULT}"
    else
      log_file "successfully compiled hello.cs"
    fi
  fi
}

run_test_file() {
   local RESULT=''
   if [[ -e /home/ec2-user/hello.exe ]]; then
     RESULT=$(mono /home/ec2-user/hello.exe > testresult);
     if [[ $? != 0 ]]; then
       log_error "failed to run hello.cs:\n${RESULT}"
     else
       log_file "successfully run hello.cs"
       if [[ "Hello Mono" == "$(cat testresult)" ]]; then
         log_file "Mono Test Success"
       else
         log_error "Mono Test Failed" 
       fi
     fi
   fi
}

clean_up() { 
  rm hello.exe testresult hello.cs
}

main
