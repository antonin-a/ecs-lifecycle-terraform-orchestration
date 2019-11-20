key_pair          = "your-keypair"
instance_name     = ""
flavor_name       = "flavor-name"
availability_zone = "eu-west-0a"
network_id        = "your-network-id"
subnet_id         = "your-subnet-id"
fixed_ip          = ""
security_groups   = ["your-sec-group-id"]
key_pair          = "your-keypair"
instance_name     = ({
                    <workspace-name-1> = "instance-1"
                    <workspace-name-2> = "instance-2"
                    <workspace-name-3> = "instance-3"
                  })
system_disk       =  ({
                    <workspace-name-1> = "system_disk-id-1"
                    <workspace-name-2> = "system_disk-id-2"
                    <workspace-name-3> = "system_disk-id-3"
                  })
data_disk         =  ({
                    <workspace-name-1> = "data_disk-id-1"
                    <workspace-name-2> = "data_disk-id-2"
                    <workspace-name-3> = "data_disk-id-3"
                  })
fixed_ip          =  ({
                   <workspace-name-1> = "private-fixed_ip-1"
                   <workspace-name-2> = "private-fixed_ip-2"
                   <workspace-name-3> = "private-fixed_ip-3"
                  })
attach_eip        = false
instance_count    = 1
