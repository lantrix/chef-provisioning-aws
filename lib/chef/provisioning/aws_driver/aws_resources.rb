class Chef
  module Provisioning
    module AWSDriver
      module AWSResources
        def self.aws_resources
          @@aws_resources ||= {}
        end

        def self.[](resource_key)
          aws_resources[resource_key]
        end
        def self.[]=(resource_key, value)
          aws_resources[resource_key] = value
        end

        def self.lookup_aws_id(managed_entries, identifier, id, scope, **options)
          aws_resource = aws_resources[identifier]
          aws_resource[:handler].lookup_aws_id(managed_entries, id, scope, **options)
        end

        def self.get_aws_object(managed_entries, driver, identifier, id, scope, **options)
          aws_resource = aws_resources[identifier]
          id = aws_resource[:handler].lookup_aws_id(managed_entries, id, scope, **options)
          if id
            aws_resource[:handler].get_aws_object(managed_entries, driver, id, scope, **options)
          else
            nil
          end
        end
      end
    end
  end
end

require 'chef/provisioning/aws_driver/aws_image'
require 'chef/provisioning/aws_driver/aws_instance'
require 'chef/provisioning/aws_driver/aws_load_balancer'
