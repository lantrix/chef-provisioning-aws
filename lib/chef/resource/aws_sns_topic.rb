require 'chef/resource/aws_resource'

class Chef::Resource::AwsSnsTopic < Chef::Resource::AwsResource
  self.resource_name = 'aws_sns_topic'

  actions :create, :delete, :nothing
  default_action :create

  attribute :name, :kind_of => String, :name_attribute => true

  def self.get_aws_object_by_id(managed_entries, driver, id, scope)
    begin
      driver.sns.topics.named(name)
    rescue
      nil
    end
  end

  register_as_aws_resource
end
