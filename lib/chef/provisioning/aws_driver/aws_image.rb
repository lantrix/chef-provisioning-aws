require 'chef/resource/aws_resource'

# DO NOT USE.  This is not filled in and exists only for looking up IDs, at the
# moment.
class Chef
  module Provisioning
    module AWSDriver
      class AwsImage < Chef::Resource::AwsResource
        def initialize(*args)
          raise NotImplementedError, "aws_image not yet implemented."
        end

        def self.get_aws_object(driver, id)
          driver.ec2.instances[id]
        end

        register_as_aws_resource(
          reference_id: 'image_id',
          aws_identifier_name: 'image_id',
          aws_identifier_prefix: 'ami',
          resource_type: 'machine_image'
        )
      end
    end
  end
end
