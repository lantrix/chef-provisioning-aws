require 'chef/provider/aws_provider'
require 'date'

class Chef::Provider::AwsSubnet < Chef::Provider::AwsProvider

  action :create do
    if current_aws_object == nil
      cidr_block = new_resource.cidr_block
      if !cidr_block
        cidr_block = get_aws_object(:vpc, vpc).cidr_block
      end
      converge_by "Creating new Subnet #{new_resource.name} with CIDR #{cidr_block} in VPC #{new_resource.vpc} in #{region}" do
        opts = { :vpc => new_resource.vpc }
        opts[:availability_zone] = new_resource.availability_zone if new_resource.availability_zone
        opts = lookup_option_ids(opts)
        subnet = new_driver.ec2.subnets.create(cidr_block, opts)
        subnet.tags['Name'] = new_resource.name
        subnet.tags['VPC'] = new_resource.vpc
        save_entry(id: subnet.id)
      end
    end
  end

  action :delete do
    if current_aws_object
      converge_by "Deleting subnet #{new_resource.name} in VPC #{new_resource.vpc} in #{region}" do
        current_aws_object.delete
      end
    end

    delete_entry
  end

end
