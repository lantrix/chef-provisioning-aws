require 'chef/provider/lwrp_base'
require 'chef/resource/aws_resource'
require 'chef/provisioning/chef_managed_entry_store'
require 'chef/provisioning/aws_driver/aws_resources'
require 'chef/provisioning/chef_provider_action_handler'


class Chef::Provider::AwsProvider < Chef::Provider::LWRPBase
  use_inline_resources

  AWSResources = Chef::Provisioning::AWSDriver::AWSResources

  def action_handler
    @action_handler ||= Chef::Provisioning::ChefProviderActionHandler.new(self)
  end

  # All these need to implement whyrun
  def whyrun_supported?
    true
  end

  def entry_id
    # TODO consider getting rid of region
    new_resource.name
  end

  def new_driver
    run_context.chef_provisioning.driver_for(new_resource.driver)
  end

  def current_driver
    run_context.chef_provisioning.driver_for(entry.driver_url)
  end

  def lookup_option_ids(options={})
    options.each do |option, value|
      options[option] = lookup_ids(option, value)
    end
  end

  def lookup_ids(identifier, value)
    # - security_group_ids
    if identifier.to_s.end_with?('s')
      identifier = identifier.to_s[0..-2].to_sym
      Array[value].flatten.map { |value| AWSResources.lookup_aws_id(managed_entries, identifier, value, self, required: true) }

    # - security_group_id
    else
      AWSResources.lookup_aws_id(managed_entries, identifier.to_sym, value, self, required: true)
    end
  end

  def vpc
    @vpc ||= current_aws_object ? current_aws_object.vpc.id : lookup_ids(:vpc, new_resource.vpc)
  end

  alias :lookup_id :lookup_ids

  def get_aws_object(identifier, id, **options)
    AWSResources.get_aws_object(managed_entries, entry ? current_driver : new_driver, identifier, id, self, **options)
  end

  def managed_entries
    new_resource.managed_entry_store
  end

  def entry
    @entry ||= managed_entries.get(AWSResources[new_resource.class][:resource_type], entry_id)
  end

  def save_entry(reference)
    entry = managed_entries.new_entry(AWSResources[new_resource.class][:resource_type], entry_id)
    entry.reference = reference
    entry.driver_url = new_driver.driver_url
    entry.save(action_handler)
  end

  def delete_entry
    managed_entries.delete(AWSResources[new_resource.class][:resource_type], entry_id, action_handler)
  end

  def region
    new_driver.aws_config.region
  end

  def aws_driver
    new_driver
  end

  def current_aws_object
    @current_aws_object = new_resource.aws_object if !defined?(@current_aws_object)
    @current_aws_object
  end
end
