require 'chef/resource/aws_resource'
require 'ipaddr'

class Chef::Resource::AwsEipAddress < Chef::Resource::AwsResource
  self.resource_name = 'aws_eip_address'

  actions :delete, :nothing, :associate, :disassociate
  default_action :associate

  attribute :name, kind_of: String, name_attribute: true

  attribute :associate_to_vpc, kind_of: [TrueClass, FalseClass], default: false
  attribute :machine,          kind_of: String

  def self.get_aws_object_by_id(managed_entries, driver, id, scope)
    driver.ec2.elastic_ips[id]
  end
  def self.lookup_aws_id(managed_entries, value, **options)
    begin
      IPAddr.new(value)
    rescue IPAddr::InvalidAddressError
      super
    end
  end

  register_as_aws_resource should_lookup_aws_id: true, backcompat_data_bag_name: 'eip_addresses'
end
