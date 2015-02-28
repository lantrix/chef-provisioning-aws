require 'chef/provisioning/aws_driver'

with_driver 'aws::eu-west-1'

aws_vpc 'ref-vpc' do
  cidr_block '10.0.0.0/24'
end

aws_security_group 'ref-sg1' do
  vpc 'ref-vpc'
end

aws_security_group 'ref-sg2' do
  vpc 'ref-vpc'

  inbound_rules [
    {:ports => 2223, :protocol => :tcp, :sources => ['ref-sg1'] }
  ]
  # outbound_rules [
  #   {:ports => 2223, :protocol => :tcp, :destinations => ['ref-sg1'] }
  # ]
end

aws_subnet 'ref-subnet' do
  vpc 'ref-vpc'
end


machine_image 'ref-machine_image1' do

end

machine_image 'ref-machine_image2' do
  from_image 'ref-machine_image1'
end

machine_image 'ref-machine_image3' do
  machine_options bootstrap_options: { subnet_id: 'ref-subnet', image_id: 'ref-machine_image1' }
end

machine_batch do
  machine 'ref-machine1' do
    from_image 'ref-machine_image1'
    machine_options bootstrap_options: { subnet_id: 'ref-subnet', }
  end
  machine 'ref-machine2' do
    machine_options bootstrap_options: { subnet_id: 'ref-subnet', image_id: 'ref-machine_image1' }
  end
end

load_balancer 'ref-load_balancer' do
  load_balancer_options :subnet_ids => 'ref-subnet'
  machines %w(ref-machine1 ref-machine2')
end
