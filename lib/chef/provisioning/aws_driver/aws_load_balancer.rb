require 'chef/resource/aws_resource'

# DO NOT USE.  This is not filled in and exists only for looking up IDs, at the
# moment.
class Chef
  module Provisioning
    module AWSDriver
      class AwsLoadBalancer < Chef::Resource::AwsResource
        def initialize(*args)
          raise NotImplementedError, "aws_load_balancer not yet implemented."
        end

        def self.get_aws_object(driver, id)
          driver.elb.load_balancers[id]
        end

        register_as_aws_resource(
          aws_identifier_name: 'load_balancer_id',
          resource_type: 'load_balancer'
        )
      end
    end
  end
end
