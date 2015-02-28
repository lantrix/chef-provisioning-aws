require 'chef/resource/aws_resource'

class Chef::Resource::AwsAutoScalingGroup < Chef::Resource::AwsResource
  self.resource_name = 'aws_auto_scaling_group'

  actions :create, :delete, :nothing
  default_action :create

  attribute :name, :kind_of => String, :name_attribute => true
  attribute :options, :kind_of => Hash, :default => {}
  attribute :desired_capacity, :kind_of => Integer
  attribute :launch_configuration, :kind_of => String
  attribute :min_size, :kind_of => Integer, :default => 1
  attribute :max_size, :kind_of => Integer, :default => 4
  attribute :load_balancers, :kind_of => Array

  def self.get_aws_object_by_id(managed_entries, driver, id, scope)
    driver.auto_scaling.groups[id]
  end

  register_as_aws_resource
end
