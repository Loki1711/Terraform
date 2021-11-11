
subscription_id = ""
client_id       = ""
client_secret   = ""
tenant_id       = ""
location        = "Central India"
RGname          = "TF-RG-test"
tags            = { Owner = "Loki", Environment = "demo" }
VNET            = ["TF-VNET-", "1"]
address_space   = ["10.0.0.0/16", "192.168.100.0/24", "172.16.0.0./16", "10.0.1.0/24"]
subnet          = ["TF-Subnet", "-1"]
PIP             = ["TF-", "PIP"]
NIC             = ["TF-", "NIC"]
NSG             = ["TF-", "NSG"]
VM              = ["TF-", "VM"]
passwd          = "Loki$890"
username        = "loki"
hostname        = "WEB"