require 'chef/resource/aws_resource'

class Chef::Resource::AwsVpc < Chef::Resource::AwsResource
  self.resource_name = 'aws_vpc'

  actions :create, :delete, :nothing
  default_action :create

  attribute :name,             kind_of: String, name_attribute: true
  attribute :cidr_block,       kind_of: String
  attribute :instance_tenancy, equal_to: [ :default, :dedicated ], default: :default

  def self.get_aws_object_by_id(managed_entries, driver, id, scope)
    driver.ec2.vpcs[id]
  end

  register_as_aws_resource aws_identifier_name: :vpc, aws_identifier_prefix: 'vpc'
end
