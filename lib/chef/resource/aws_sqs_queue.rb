require 'chef/resource/aws_resource'

class Chef::Resource::AwsSqsQueue < Chef::Resource::AwsResource
  self.resource_name = 'aws_sqs_queue'

  actions :create, :delete, :nothing
  default_action :create

  attribute :name,    kind_of: String, name_attribute: true
  attribute :options, kind_of: Hash

  def self.get_aws_object_by_id(managed_entries, driver, id, scope)
    begin
      driver.sqs.queues.named(name)
    rescue
      nil
    end
  end

  register_as_aws_resource
end
