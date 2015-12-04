#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'byebug'
require 'trollop'
require 'yaml'
require 'logger'

require 'aws-sdk'
require 'pp'

class MyAws
  attr_accessor :access_key_id, :secret_access_key, :region, :verbose
  attr_accessor :match

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

  def loop_instances
    puts "#{__method__}"
    ec2_instances = Aws::EC2::Resource.new.instances
    tags_hash = instance_collection(ec2_instances)

    puts "   *** #{ec2_instances.count} Instances ***"
    ec2_instances.map do |instance|
      unless match.empty?
        next if tags_hash[instance.instance_id]["Name"].nil?
        next unless tags_hash[instance.instance_id]["Name"].include?(match)
      end
      yield(instance, tags_hash)
    end
  end

  def query_instances
    puts "#{__method__}"
    loop_instances do |instance, tags_hash|
      puts "    ++++++++++++++++++++++++ Instance +++++++++++++++++++++++++"
      print_instance(instance, tags_hash)
    end
  end

  def query_security_groups
    puts "#{__method__}"
    ec2_security_groups = Aws::EC2::Resource.new.security_groups
    puts "   *** #{ec2_security_groups.count} Security Groups ***"
    ec2_security_groups.map do |sg|
      puts "    +++++++++++++++++++++ Security Group  +++++++++++++++++++++"
      print_security_group(sg)
    end
  end

  def start_instance
    puts "#{__method__}"
    loop_instances do |instance, _tags_hash|
      instance.start
    end
  end

  def stop_instance
    puts "#{__method__}"
    loop_instances do |instance, _tags_hash|
      instance.stop
    end
  end

  def reboot_instance
    puts "#{__method__}"
    loop_instances do |instance, _tags_hash|
      instance.reboot
    end
  end

  def terminate_instance
    puts "#{__method__}"
    loop_instances do |instance, _tags_hash|
      instance.terminate
    end
  end

  private

  def instance_collection(instances)
    puts "#{__method__}"
    tags_hash = {}
    instances.each_with_object(tags_hash) do |item, hash|
      item_hash = {}
      item.tags.each_with_object(item_hash) { |i, h| h[i.key] = i.value }
      hash[item.id] = item_hash
    end
    tags_hash
  end

  def tags_to_h(tags)
    puts "#{__method__}"
    tags_hash = {}
    tags.each_with_object(tags_hash) do |item, hash|
      hash[item[0]] = item[1]
    end
    tags_hash
  end

  def print_ip_permissions(ip_permissions)
    puts "#{__method__}"
    ip_permissions.each do |item|
      puts item.to_yaml
    end
  end

  def print_security_group(sg)
    puts "#{__method__}"
    puts "sg.inspect                 #{sg.inspect}\n"
    puts "description                #{sg.description}\n"
    puts "group_id                   #{sg.group_id}\n"
    puts "group_name                 #{sg.group_name}\n"
    puts "id                         #{sg.id}\n"
    puts "owner_id                   #{sg.owner_id}\n"
    puts "vpc_id                     #{sg.vpc_id}\n"
    puts "ip_permissions             #{sg.ip_permissions.inspect}\n"
    puts "ip_permissions_egress      #{sg.ip_permissions_egress.inspect}\n"
    puts "Aws::EC2::Resource.new.vpc(sg.vpc_id)  #{Aws::EC2::Resource.new.vpc(sg.vpc_id)}\n"
    puts "ip_permissions"
      print_ip_permissions(sg.ip_permissions)
    puts "ip_permissions"
      print_ip_permissions(sg.ip_permissions)
    puts "ip_permissions_egress"
      print_ip_permissions(sg.ip_permissions_egress)
    puts "tags                       #{tags_to_h(sg.tags)}\n"
    puts "inspect                    #{sg.inspect}\n"
    puts "client                     #{sg.client}\n"
    puts "to_yaml_properties         #{sg.to_yaml_properties}\n"
    puts "psych_to_yaml              #{sg.psych_to_yaml}\n"
    puts "to_yaml                    #{sg.to_yaml}\n"
  end

  def print_instance(instance, tags_hash)
    puts "#{__method__}"
    puts "Name(tags)            #{tags_hash[instance.instance_id]["Name"]}\n"
    puts "state                 #{instance.state}\n"
    puts "ami_launch_index      #{instance.ami_launch_index}\n"
    puts "architecture          #{instance.architecture}\n"
    puts "block_device_mappings #{instance.block_device_mappings}\n"
    puts "client_token          #{instance.client_token}\n"
    puts "ebs_optimized         #{instance.ebs_optimized}\n"
    puts "hypervisor            #{instance.hypervisor}\n"
    puts "image_id              #{instance.image_id}\n"
    puts "instance_id           #{instance.instance_id}\n"
    puts "instance_type         #{instance.instance_type}\n"
    puts "kernel_id             #{instance.kernel_id}\n"
    puts "key_name              #{instance.key_name}\n"
    puts "launch_time           #{instance.launch_time}\n"
    puts "monitoring            #{instance.monitoring}\n"
    puts "network_interfaces    #{instance.network_interfaces}\n"
    puts "placement             #{instance.placement}\n"
    puts "private_dns_name      #{instance.private_dns_name}\n"
    puts "private_ip_address    #{instance.private_ip_address}\n"
    puts "product_codes         #{instance.product_codes}\n"
    puts "public_ip_address     #{instance.public_ip_address}\n"
    puts "root_device_name      #{instance.root_device_name}\n"
    puts "root_device_type      #{instance.root_device_type}\n"
    puts "virtualization_type   #{instance.virtualization_type}\n\n"
  end
end

def stupid_simple_get_opts
  args = Trollop::options do
    opt :access_key_id,      "AWS account access key id",                        :type => :string
    opt :secret_access_key,  "AWS secret access key",                            :type => :string
    opt :region,             "e.g.: us-east-1, us-west-2, us-west-1, eu-sest-1", :default => 'us-east-1'
    opt :verbose,            "Verbose output",                                   :default => true
    opt :query_type,         "Query Type instance|security_groups",              :default => "instance"
    opt :instance_action,    "Instance Action stop|start|reboot|terminate",      :default => "stop"
    opt :match,              "action must match specified string",               :default => ""
  end

  args
end

opts = stupid_simple_get_opts
puts "opts ->#{opts}<-"
my_aws = MyAws.new(opts)

if opts[:query_type_given]
  my_aws.query_instances       if opts[:query_type] == "instance"
  my_aws.query_security_groups if opts[:query_type] == "security_groups"
end

if opts[:instance_action_given]
  my_aws.start_instance        if opts[:instance_action] == "start"
  my_aws.stop_instance         if opts[:instance_action] == "stop"
  my_aws.reboot_instance       if opts[:instance_action] == "reboot"
  my_aws.terminate_instance    if opts[:instance_action] == "terminate"
end
