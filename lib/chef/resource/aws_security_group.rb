require 'chef/resource/aws_resource'
require 'chef/provisioning/aws_driver/aws_resources'

class Chef::Resource::AwsSecurityGroup < Chef::Resource::AwsResource
  self.resource_name = 'aws_security_group'

  actions :create, :delete, :nothing
  default_action :create

  attribute :name,          kind_of: String, name_attribute: true
  attribute :vpc,           kind_of: String
  attribute :description,   kind_of: String
  attribute :inbound_rules
  attribute :outbound_rules

  def self.get_aws_object_by_id(managed_entries, driver, id, scope)
    vpc = scope.vpc
    vpc ||= driver.ec2.vpcs.filter('is-default', 'true').first.id
    vpc = Chef::Provisioning::AWSDriver::AWSResources.lookup_aws_id(managed_entries, :vpc, vpc, scope)
    driver.ec2.vpcs[vpc].security_groups.filter('group-name', id).first
  end

  register_as_aws_resource
end
