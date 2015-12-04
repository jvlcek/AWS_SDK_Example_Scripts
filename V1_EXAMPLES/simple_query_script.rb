#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'byebug'
require 'trollop'

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

    config_args = {:access_key_id     => access_key_id,
                   :secret_access_key => secret_access_key,
                   :region            => region}

    if verbose
      config_args[:log_level]       = :debug
      config_args[:logger]          = Logger.new($stdout)
      config_args[:http_wire_trace] = true
    end

    AWS.config(config_args)
  end

  def loop_instances
    puts "#{__method__}"
    ec2_instances = AWS.ec2.instances
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
    ec2_security_groups = AWS.ec2.security_groups
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
      hash[item.id] = item.tags.to_h
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
    puts "security_group_id          #{sg.security_group_id}\n"
    puts "group_id                   #{sg.group_id}\n"
    puts "id                         #{sg.id}\n"
    puts "name                       #{sg.name}\n"
    puts "owner_id                   #{sg.owner_id}\n"
    puts "vpc_id                     #{sg.vpc_id}\n"
    puts "description                #{sg.description}\n"
    puts "ip_permissions_list        #{sg.ip_permissions_list.inspect}\n"
    puts "ip_permissions_list_egress #{sg.ip_permissions_list_egress.inspect}\n"
    puts "instances                  #{instance_collection(sg.instances)}\n"
    puts "exists?                    #{sg. exists?}\n"
    puts "vpc?                       #{sg. vpc?}\n"
    puts "vpc                        #{sg.vpc}\n"
    puts "ingress_ip_permissions"
    print_ip_permissions(sg.ingress_ip_permissions)
    puts "ingress_ip_permissions"
    print_ip_permissions(sg.ingress_ip_permissions)
    puts "egress_ip_permissions"
    print_ip_permissions(sg.egress_ip_permissions)
    puts "resource_type              #{sg.resource_type}\n"
    puts "inflected_name             #{sg.inflected_name}\n"
    puts "describe_call_name         #{sg.describe_call_name}\n"
    puts "tags                       #{tags_to_h(sg.tags)}\n"
    puts "cached_tags                #{sg.cached_tags}\n"
    puts "tagging_resource_type      #{sg.tagging_resource_type}\n"
    puts "inspect                    #{sg.inspect}\n"
    puts "client                     #{sg.client}\n"
    puts "config_prefix              #{sg.config_prefix}\n"
    puts "to_yaml_properties         #{sg.to_yaml_properties}\n"
    puts "psych_to_yaml              #{sg.psych_to_yaml}\n"
    puts "to_yaml                    #{sg.to_yaml}\n"
  end

  def print_instance(instance, tags_hash)
    puts "#{__method__}"

    puts "Name(tags)            #{tags_hash[instance.instance_id]["Name"]}\n"
    puts "status                #{instance.status}\n"
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
    puts "network_interface_set #{instance.network_interface_set}\n"
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
