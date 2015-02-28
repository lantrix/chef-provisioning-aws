require 'chef/resource/aws_resource'

# DO NOT USE.  This is not filled in and exists only for looking up IDs, at the
# moment.
class Chef
  module Provisioning
    module AWSDriver
      class AwsInstance < Chef::Resource::AwsResource
        def initialize(*args)
          raise NotImplementedError, "aws_instance not yet implemented."
        end

        def self.get_aws_object(driver, id)
          driver.ec2.instances[id]
        end

        register_as_aws_resource(
          reference_id: 'instance_id',
          aws_identifier_name: 'instance_id',
          aws_identifier_prefix: 'i',
          resource_type: 'machine'
        )
      end
    end
  end
end
