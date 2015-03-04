require 'chef/provider/aws_provider'
require 'cheffish'
require 'date'

class Chef::Provider::ProvAwsEbsVolume < Chef::Provider::AwsProvider
  provides :aws_ebs_volume
  
  action :create do
    if existing_volume == nil
      converge_by "Creating new EBS volume #{fqn} in #{new_driver.aws_config.region}" do

        ebs = new_driver.ec2.volumes.create(
            :availability_zone => new_resource.availability_zone,
            :size => new_resource.size.to_i
        )
        ebs.tags['Name'] = fqn

        new_resource.created_at DateTime.now.to_s
        new_resource.volume_id ebs.id

      end
    else
      new_resource.volume_id existing_volume.id
    end

    new_resource.save
  end

  action :delete do
    if existing_volume
      converge_by "Deleting EBS volume #{fqn} in #{new_driver.aws_config.region}" do
        existing_volume.delete
      end
    end

    new_resource.delete
  end


  def existing_volume
    @existing_volume ||=  new_resource.volume_id == nil ? nil : begin
      Chef::Log.debug("Loading volume #{new_resource.volume_id}")
      volume = new_driver.ec2.volumes[new_resource.volume_id]
      if [:deleted, :deleting, :error].include? volume.status
        nil
      else
        Chef::Log.debug("Found EBS volume #{volume.inspect}")
        volume
      end
    rescue => e
      Chef::Log.error("Error looking for EBS volume: #{e}")
      nil
    end
  end

  def id
    new_resource.volume_name
  end

end
