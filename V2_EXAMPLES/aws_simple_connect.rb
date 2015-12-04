#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'trollop'
require 'logger'

require 'aws-sdk'
require 'pp'

class MyAws
  attr_accessor :access_key_id, :secret_access_key, :region, :verbose

  def initialize(opt)
    puts "#{__method__}"
    @access_key_id     = opt[:access_key_id]
    @secret_access_key = opt[:secret_access_key]
    @region            = opt[:region]
    @verbose           = opt[:verbose]
    @match             = opt[:match]

    config_args = {:region => region}
    if verbose
      config_args[:log_level]       = :debug
      config_args[:logger]          = Logger.new($stdout)
      config_args[:http_wire_trace] = true
    end

    aws_creds = Aws::Credentials.new(access_key_id, secret_access_key)
    Aws.config.update(config_args.merge(:credentials => aws_creds))
  end

  def count_instances
    puts "#{__method__}"
    ec2_instances = Aws::EC2::Resource.new.instances
    puts "   *** #{ec2_instances.count} Instances ***"
  end
end

def stupid_simple_get_opts
  args = Trollop::options do
    opt :access_key_id,      "AWS account access key id",                        :type => :string
    opt :secret_access_key,  "AWS secret access key",                            :type => :string
    opt :region,             "e.g.: us-east-1, us-west-2, us-west-1, eu-sest-1", :default => 'us-east-1'
    opt :verbose,            "Verbose output",                                   :default => true
  end

  args
end

if __FILE__ == $PROGRAM_NAME
  opts = stupid_simple_get_opts
  puts "opts ->#{opts}<-"
  my_aws = MyAws.new(opts)
  my_aws.count_instances
end
