# AWS_SDK_Example_Scripts

## aws_simple_connect.rb
---------------------

  Is a simple ruby script that will confirm connectivity to an AWS account
  by attempting to return the count of instances available to the account,
  even if there are non.

###  # Display help/usage

```
gem install bundler
bundle exec ./aws_simple_connect.rb -h
```

### Ping AWS account by counting instances, even if there are none.

```
bundle exec ./aws_simple_connect.rb -a <Your AWS account access key id> -s <Your AWS secret access key>
```

### Pass argument --no-verbose to turn off the extra diagnostics 
