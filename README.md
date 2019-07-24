## terraform.tfvars Generator

Script will generate the terraform.tfvars file in the same directory where you run it.
Simply pass zero or more (see --help) necessary flags to the script and it will generate a new terraform.tfvars file for you.

***WARNING!!! It will rewrite any terraform.tfvars files in the direcotry where the script is executed***

### Optional flags can be passed to the script

Source of the aws credentials file _(default is ~/.aws/credentials)_:
```sh
./tfvars-gen.sh --credentials=/path/to/the/credentials
```
AWS Profile _(default profile is "default")_:
```sh
./tfvars-gen.sh --profile=my_profile
```
GitHub Token _(default is "0000")_:
```sh
./tfvars-gen.sh --gtoken=1234567890
```
AWS Key file and it's path with trailing slash _(default "/", "key.pem")_:
```sh
./tfvars-gen.sh --key-path=</foo/bar/ --key-name=my_key.pem
```
Several flags can be set at one time:
```sh
./tfvars-gen.sh --profile=my_profile --gtoken=1234567890
                    OR
./tfvars-gen.sh --credentials=/path/to/the/credentials --profile=my_profile --gtoken=1234567890
```
#### Output of the generated terraform.tfvars will be similar to this:

````
aws_access_key = "ABCDEFG123456"
aws_secret_key = "ABCDEFGHIJKLM12345678"
aws_session_token = "ABCD...LONG..TOKEN...HERE...12345"
aws_key_path = "/"
aws_key_name = "key"
github_token = "abcd1234efgh"
````
