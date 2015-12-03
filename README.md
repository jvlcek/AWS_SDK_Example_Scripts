# AWS_SDK_Example_Scripts

# These are aws-sdk v1 and v2 examples

Even though aws-sdk v1 and v2 can be used in the same program
the scripts here are reimplemented for both aws-sdk v1 and v2.

This is done to help readers quickly and easily identify the
differences when using each of the API versions

Under both directories V1_EXAMPLES and V2_EXAMPLES exists the
following:

## aws_simple_connect.rb
---------------------

  Is a simple ruby script that will confirm connectivity to an AWS account
  by attempting to return the count of instances available to the account,
  even if there are non.

###  Display help/usage

```
gem install bundler
bundle exec ./aws_simple_connect.rb -h
```

### Ping AWS account by counting instances, even if there are none.

```
bundle exec ./aws_simple_connect.rb -a <Your AWS account access key id> -s <Your AWS secret access key>
```

### Pass argument --no-verbose to turn off the extra diagnostics 


## simple_query_script.rb
---------------------

  Is a simple ruby script that will access the AWS account to:
  * query instances
  * query security_groups
  * perform actions on instances

###  Display help/usage

```
gem install bundler
bundle exec ./simple_query_script.rb -h
```

### Query Instances whos Tag: "Name" contain the string "joev"

```
bundle exec ./aws_simple_connect.rb -a <Your AWS account access key id> -s <Your AWS secret access key> -q -m "joev"
```

### Query Security Groups

```
bundle exec ./aws_simple_connect.rb -a <Your AWS account access key id> -s <Your AWS secret access key> -q security_groups
```

### Pass argument --no-verbose to turn off the extra diagnostics 



