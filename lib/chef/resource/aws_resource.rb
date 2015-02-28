require 'chef/resource/lwrp_base'
require 'chef/provisioning/chef_managed_entry_store'

# Common AWS resource - contains metadata that all AWS resources will need
class Chef::Resource::AwsResource < Chef::Resource::LWRPBase
  attribute :driver
  attribute :chef_server

  def initialize(*args)
    super
    @driver = run_context.chef_provisioning.current_driver
    @chef_server = run_context.cheffish.current_chef_server
  end

  #
  # Get the AWS driver
  #
  def aws_driver
    run_context.chef_provisioning.driver_for(driver)
  end

  #
  # Get the ID from the current location.  nil if not exists.
  #
  def aws_id
    self.class.lookup_aws_id(managed_entry_store, self, self)
  end

  def managed_entry_store
    Chef::Provisioning::ChefManagedEntryStore.new(chef_server)
  end

  #
  # Get the AWS thingy that corresponds to this resource.
  #
  def aws_object
    self.class.get_aws_object(managed_entry_store, aws_driver, aws_id, self)
  end

  #
  # Machinery for lookup_aws_id and get_aws_object
  #

  #
  # Get the actual AWS object for the given id.
  #
  # The id will be looked up by `lookup_aws_id(managed_entries, value)` before
  #
  # @param managed_entries [Chef::Provisioning::ManagedEntryStore] The storage
  #        where AWS IDs are associated with Chef names.
  # @param driver [Chef::Provisioning::Driver] The driver from which to get the
  #        object.
  # @param value The ID of the object; will be looked up by `lookup_aws_id`.
  # @param required `true` if an error should be raised when the object does not
  #        exist.  The deepest error possible (such as the 404 response) will be
  #        raised.  If the input value is `nil`, `nil` will be returned rather
  #        than an error raised.
  #
  # @return The actual AWS object.  If the AWS object doesn't exist, the method
  #         may either return `nil` or an AWS object where `.exists?` is `false`.
  #
  def self.get_aws_object(managed_entries, driver, value, scope, required: false)
    id = lookup_aws_id(managed_entries, value, scope, required: required)
    if id
      result = get_aws_object_by_id(managed_entries, driver, id, scope)
      if !result || !result.exists?
        raise "#{self.class} #{id.inspect} does not exist" if required
        return nil
      end
    end
    result
  end

  #
  # Look up the AWS ID for the given input.
  #
  # This may be different for each object, but the general pattern is:
  # - If the input is `nil`, `nil` is returned.
  # - If the value is a Resource, `lookup_aws_id(resource.name)`` is called.
  # - If the AWS object in question already uses `name` as its unique ID, no
  #   lookup is performed.
  # - If the value is already in the form AWS expects (such as ami-12ae4f10), no
  #   lookup is performed.
  # - If the value is a String and not in the AWS expected form, the corresponding
  #   object in Chef is looked up via `managed_entries.get` and the ID extracted
  #   from there.  For example, if `mario` is passed as an `instance_id`, the
  #   `mario` node is retrieved in Chef, and the `instance_id` is extracted from
  #   its `location` attribute.
  #
  # @param managed_entries [Chef::Provisioning::ManagedEntryStore] The storage
  #        where AWS IDs are associated with Chef names.
  # @param driver [Chef::Provisioning::Driver] The driver from which to get the
  #        object.
  # @param value [Chef::Resource,String,nil] The ID of the object; will be looked up by `lookup_aws_id`.
  # @param scope The object doing the retrieval.  Should have `vpc` as a property.
  # @param required `true` if an error should be raised when the object does not
  #        exist.  The deepest error possible (such as the 404 response) will be
  #        raised.  If the input value is `nil`, `nil` will be returned rather
  #        than an error raised.
  #
  # @return The actual AWS object.  If the AWS object doesn't exist, the method
  #         may either return `nil` or an AWS object where `.exists?` is `false`.
  #
  def self.lookup_aws_id(managed_entries, value, scope, required: false)
    options = Chef::Provisioning::AWSDriver::AWSResources[self]

    case value
    # A nil
    when nil
      value

    # A Resource was passed in.  Look it up by the resource name.
    when Chef::Resource
      lookup_aws_id(managed_entries, value.name, scope, required: required)

    # A String matching <id>-<hex> in AWS format; pass through.
    when /^#{options[:aws_identifier_prefix]}-[A-Fa-f0-9]{8}$/
      value

    # It's a name!  Look it up.
    else
      return value if !options[:should_lookup_aws_id]

      if required
        entry = managed_entries.get!(options[:resource_type], value)
      else
        entry = managed_entries.get(options[:resource_type], value)
      end

      if entry
        entry.reference[options[:reference_id]]
      else
        nil
      end
    end
  end

  protected

  #
  # Called by subclasses to register themselves as AWS resources.
  #
  # @param aws_identifier_name [String] The name the AWS SDK generally uses to
  #        refer to this resource in arguments and options.  Defaults to `<resource_type>_id`.
  # @param aws_identifier_prefix [String] The prefix for AWS identifiers of this type, e.g. `ami`, `i`, `subnet` or `sg`
  # @param backcompat_data_bag_name [String] The place where this data bag used to be stored before Provisioning data bag storage was changed.  Defaults to `nil`.
  # @param handler An object with `get_aws_object(driver, id)` and `lookup_aws_id(managed_entry_store, value)` methods.  Defaults to `self`.
  # @param reference_id [String] The ID to retrieve from `managed_entry`, e.g. `managed_entry.location[<id>]`.  Defaults to `id`.
  # @param resource_type [String] The resource name to use for retrieving `managed_entry` from the managed entry store.  Defaults to this Resource's `resource_name`.
  # @param should_lookup_aws_id [Boolean] `true` if the resource has managed entries in storage that should be looked up.  Defaults to `true` if `aws_identifier_prefix` is set, `false` otherwise.
  #
  def self.register_as_aws_resource(
              aws_identifier_name: nil,
              aws_identifier_prefix: nil,
              backcompat_data_bag_name: nil,
              handler: self,
              reference_id: 'id',
              resource_type: nil,
              should_lookup_aws_id: nil
            )
    resource_type ||= self.resource_name.to_sym
    should_lookup_aws_id ||= !!aws_identifier_prefix
    aws_identifier_name ||= "#{resource_type[4..-1]}_id".to_sym # aws_subnet -> subnet_id
    options = {
      aws_identifier_name: aws_identifier_name,
      aws_identifier_prefix: aws_identifier_prefix,
      backcompat_data_bag_name: backcompat_data_bag_name,
      handler: handler,
      reference_id: reference_id,
      resource_type: resource_type,
      should_lookup_aws_id: should_lookup_aws_id
    }
    Chef::Provisioning::AWSDriver::AWSResources[aws_identifier_name] = options
    Chef::Provisioning::AWSDriver::AWSResources[self] = options
    if backcompat_data_bag_name
      Chef::Provisioning::ChefManagedEntryStore.type_names_for_backcompat[resource_type] = backcompat_data_bag_name
    end
  end

  #
  # Get the actual AWS object for the given id.
  #
  # Designed to be overridden by each resource; users will call get_aws_object.
  #
  # @param driver [Chef::Provisioning::Driver] The driver from which to get the object.
  # @param id The ID (in AWS format) of the object.
  #
  # @return The actual AWS object.  If the AWS object doesn't exist, the method
  #         may either return `nil` or an AWS object where `.exists?` is `false`.
  #
  def self.get_aws_object_by_id(managed_entries, driver, id, scope)
    raise NotImplementedError, :get_aws_object_by_id
  end

  # Required here to prevent cycles
  require 'chef/provisioning/aws_driver/aws_resources'
end
