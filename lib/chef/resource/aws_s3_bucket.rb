require 'chef/resource/aws_resource'

class Chef::Resource::AwsS3Bucket < Chef::Resource::AwsResource
  self.resource_name = 'aws_s3_bucket'

  actions :create, :delete, :nothing
  default_action :create

  attribute :name, :kind_of => String, :name_attribute => true
  attribute :options, :kind_of => Hash, :default => {}
  attribute :enable_website_hosting, :kind_of => [TrueClass, FalseClass], :default => false
  attribute :website_options, :kind_of => Hash

  def self.get_aws_object_by_id(managed_entries, driver, id, scope)
    driver.s3.buckets[id]
  end

  register_as_aws_resource
end
