#!/bin/bash

set -e

# Disclamer:
#
# cfg_parser - Parse and ini files into variables
# By Andres J. Diaz
# http://theoldschooldevops.com/2008/02/09/bash-ini-parser/
# Use pastebin link WordPress corrupts the script text
# http://pastebin.com/f61ef4979 (original)
# http://pastebin.com/m4fe6bdaf (supports spaces in values)
#

cfg_parser ()
{
  IFS=$'\n' && ini=( $(<$1) ) # convert to line-array
  ini=( ${ini[*]//;*/} )      # remove comments ;
  ini=( ${ini[*]//\#*/} )     # remove comments #
  ini=( ${ini[*]/\	=/=} )  # remove tabs before =
  ini=( ${ini[*]/=\	/=} )   # remove tabs be =
  ini=( ${ini[*]/\ *=\ /=} )   # remove anything with a space around  =
  ini=( ${ini[*]/#[/\}$'\n'cfg.section.} ) # set section prefix
  ini=( ${ini[*]/%]/ \(} )    # convert text2function (1)
  ini=( ${ini[*]/=/=\( } )    # convert item to array
  ini=( ${ini[*]/%/ \)} )     # close array parenthesis
  ini=( ${ini[*]/%\\ \)/ \\} ) # the multiline trick
  ini=( ${ini[*]/%\( \)/\(\) \{} ) # convert text2function (2)
  ini=( ${ini[*]/%\} \)/\}} ) # remove extra parenthesis
  ini[0]="" # remove first element
  ini[${#ini[*]} + 1]='}'    # add the last brace
  eval "$(echo "${ini[*]}")" # eval the result
}

display_help ()
{
  echo -e "\n Usage: $0 [--credentials=<path>] [--profile=<name>] [--gtoken=<github token>] [--key-path=</foo/bar/>] [--key-name=<key.pem>] \n"
  echo -e "  Default --credentials is '~/.aws/credentials' \n"
  echo -e "  Default --profile is 'default' \n"
}

for i in "$@"
do
case $i in
    --credentials=*)
    CREDENTIALS="${i#*=}"
    shift # past argument=value
    ;;
    --profile=*)
    PROFILE="${i#*=}"
    shift # past argument=value
    ;;
    --gtoken=*)
    TOKEN="${i#*=}"
    shift # past argument=value
    ;;
    --key-path=*)
    AWS_KEY_PATH="${i#*=}"
    shift # past argument=value
    ;;
    --key-name=*)
    AWS_KEY_NAME="${i#*=}"
    shift # past argument=value
    ;;
    --help)
    display_help
    exit 0
    ;;
    *)
    # unknown option
    echo "Unknown option $1"
    display_help
    exit 1
    ;;
esac
done


# Set default values

CREDENTIALS=${CREDENTIALS:-~/.aws/credentials}
PROFILE=${PROFILE:-default}
AWS_KEY_PATH=${AWS_KEY_PATH:-/}
AWS_KEY_NAME=${AWS_KEY_NAME:-key.pem}
GITHUB_TOKEN=${TOKEN:-00000}

# Do the magic of cfg_parser

if [[ ! -r "${CREDENTIALS}" ]]; then
  echo "File not found: '${CREDENTIALS}'"
  exit 3
fi

cfg_parser "${CREDENTIALS}"
if [[ $? -ne 0 ]]; then
  echo "Parsing credentials file '${CREDENTIALS}' failed"
  exit 4
fi

cfg.section.${PROFILE}
if [[ $? -ne 0 ]]; then
  echo "Profile '${PROFILE}' not found"
  exit 5
else

  echo "aws_access_key_id = \"${aws_access_key_id}\"" > terraform.tfvars &&
  echo "aws_secret_access_key = \"${aws_secret_access_key}\"" >> terraform.tfvars

  # If no token in profile then skip it in outpout file
  if [[ ${aws_session_token} ]]; then
      echo "aws_session_token = \"${aws_session_token}\"" >> terraform.tfvars
  fi

  echo "aws_key_path = \"${AWS_KEY_PATH}\"" >> terraform.tfvars
  echo "aws_key_name = \"${AWS_KEY_NAME}\"" >> terraform.tfvars
  echo "github_token = \"${GITHUB_TOKEN}\"" >> terraform.tfvars
  echo -e "Done! Enjoy your terraform! \n"
fi

exit 0
