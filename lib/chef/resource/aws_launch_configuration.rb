require 'chef/resource/aws_resource'

class Chef::Resource::AwsLaunchConfiguration < Chef::Resource::AwsResource
  self.resource_name = 'aws_launch_configuration'

  actions :create, :delete, :nothing
  default_action :create

  attribute :name,          kind_of: String, name_attribute: true
  attribute :image,         kind_of: String
  attribute :instance_type, kind_of: String
  attribute :options,       kind_of: Hash,   default: {}

  def self.get_aws_object_by_id(managed_entries, driver, id, scope)
    driver.ec2.launch_configurations[id]
  end

  register_as_aws_resource
end
