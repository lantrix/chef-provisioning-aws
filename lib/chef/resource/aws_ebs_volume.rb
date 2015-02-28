require 'chef/resource/aws_resource'

class Chef::Resource::AwsEbsVolume < Chef::Resource::AwsResource
  self.resource_name = 'aws_ebs_volume'

  actions :create, :delete, :nothing
  default_action :create

  attribute :name,    kind_of: String, name_attribute: true

  attribute :availability_zone, kind_of: String
  attribute :size,              kind_of: Integer
  attribute :snapshot,          kind_of: String

  attribute :iops,              kind_of: Integer
  attribute :volume_type,       kind_of: Symbol
  attribute :encrypted,         kind_of: [ TrueClass, FalseClass ]

  def self.get_aws_object_by_id(managed_entries, driver, id, scope)
    driver.ec2.volumes[id]
  end

  register_as_aws_resource aws_identifier_prefix: 'vol', backcompat_data_bag_name: 'ebs_volumes'
end
