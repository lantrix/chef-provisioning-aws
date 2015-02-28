require 'chef/resource/aws_resource'

class Chef::Resource::AwsSubnet < Chef::Resource::AwsResource
  self.resource_name = 'aws_subnet'

  actions :create, :delete, :nothing
  default_action :create

  attribute :name,              kind_of: String, name_attribute: true
  attribute :cidr_block,        kind_of: String
  attribute :vpc,               kind_of: String
  attribute :availability_zone, kind_of: String

  def self.get_aws_object_by_id(managed_entries, driver, id, scope)
    driver.ec2.subnets[id]
  end

  register_as_aws_resource aws_identifier_prefix: 'subnet'
end
