@description('AKS cluster name')
param clusterName string = 'AKS-Cluster'

@description('Resource group name')
param resourceGroupName string

@description('Location for all resources')
param location string = resourceGroup().location

@description('The number of nodes for the cluster')
@minValue(1)
@maxValue(8)
param agentCount int = 2

@description('User name for the Linux Virtual Machines.')
param linuxAdminUsername string = 'ubuntu'

@description('Admin password for VMs')
@secure()
param adminPassword string = ''

@description('Configure all linux machines with the SSH RSA public key string.')
param sshRSAPublicKey string

// Network configuration parameters
param vnetAddressPrefixes array = [
  '192.168.0.0/24'   // Management subnet
  '10.16.0.0/24'     // Gateway subnet
  '192.168.2.0/24'   // Web servers subnet
  '192.168.1.0/24'   // Client-facing subnet
  '192.168.8.0/24'   // Kubernetes subnet
]

param subnets array = [
  {
    name: 'GatewaySubnet'
    addressPrefix: '10.16.0.0/24'
  }  
  {
    name: 'company-subnet-management'
    addressPrefix: '192.168.0.0/24'
    nsgName: 'company-nsg-management'
  }
  {
    name: 'company-subnet-clientfacing'
    addressPrefix: '192.168.1.0/24'
    nsgName: 'company-nsg-clientfacing'
  }
  {
    name: 'company-subnet-webservers'
    addressPrefix: '192.168.2.0/24'
    nsgName: 'company-nsg-webservers'
  }
  {
    name: 'company-subnet-kubernetes'
    addressPrefix: '192.168.8.0/24'
    nsgName: 'company-nsg-kubernetes'
  }
]


var companyAuthorizedIPs = [
  '88.131.68.200'
  '88.131.68.201'
  '88.131.68.202'
]

output nsgIds array = [for subnet in subnets: subnet.nsgName != '' ? {
  name: subnet.nsgName
  id: resourceId('Microsoft.Network/networkSecurityGroups', subnet.nsgName)
} : {}]

resource networkSecurityGroups 'Microsoft.Network/networkSecurityGroups@2024-03-01' = [for subnet in subnets: if (subnet.nsgName != '') {
  name: subnet.nsgName
  location: location
  properties: {
    securityRules: subnet.name == 'company-subnet-management' ? [
      {
        name: 'SSHFromCompany'
        properties: {
          priority: 200
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Tcp'
          sourceAddressPrefixes: companyAuthorizedIPs
          sourcePortRange: '*'
          destinationAddressPrefixes: ['*']
          destinationPortRange: '22'
        }
      }
    ] : []
  }
}]



@description('Network Security Group IDs')
param nsgIds array

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-03-01' = {
  name: 'company-vnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: vnetAddressPrefixes
    }
    subnets: [for (subnet, index) in subnets: {
      name: subnet.name
      properties: {
        addressPrefix: subnet.addressPrefix
        networkSecurityGroup: subnet.nsgName != '' ? {
          id: nsgIds[index].id
        } : null
      }
    }]
  }
}

output vnetName string = virtualNetwork.name





var blobStorageBase = 'storageblob'
var randomNumber = uniqueString(resourceGroupName)

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: '${blobStorageBase}${randomNumber}'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    publicNetworkAccess: 'Enabled'
  }
}

output storageAccountName string = storageAccount.name




@description('Virtual Network name')
param vnetName string


resource managementPublicIP 'Microsoft.Network/publicIPAddresses@2024-03-01' = {
  name: 'company-vm-mgmt1-public-ip'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource managementNetworkInterface 'Microsoft.Network/networkInterfaces@2024-03-01' = {
  name: 'company-vm-mgmt1-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, 'company-subnet-management')
          }
          publicIPAddress: {
            id: managementPublicIP.id
          }
        }
      }
    ]
  }
}
resource shsNetworkInterface 'Microsoft.Network/networkInterfaces@2024-03-01' = {
  name: 'company-vm-shs1-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, 'company-subnet-webservers')
          }
        }
      }
    ]
  }
}

resource managementVM 'Microsoft.Compute/virtualMachines@2024-07-01' = {
  name: 'company-vm-mgmt1'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B1s'
    }
    osProfile: {
      computerName: 'company-vm-mgmt1'
      adminUsername: linuxAdminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-focal-daily'
        sku: 'standard_lrs'
        version: 'latest'
      }
      osDisk: {
        name: 'company-vm-mgmt1-os-disk'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
        diskSizeGB: 30
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: managementNetworkInterface.id
        }
      ]
    }
  }
}

resource shsVM 'Microsoft.Compute/virtualMachines@2024-07-01' = {
  name: 'company-vm-shs1'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B1s'
    }
    osProfile: {
      computerName: 'company-vm-shs1'
      adminUsername: linuxAdminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-focal-daily'
        sku: '20_04-daily-lts-gen2'
        version: 'latest'
      }
      osDisk: {
        name: 'company-vm-shs1-os-disk'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
        diskSizeGB: 30
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: shsNetworkInterface.id
        }
      ]
    }
  }
}




@description('Kubernetes subnet name')
param kubernetesSubnetName string

resource aks 'Microsoft.ContainerService/managedClusters@2024-08-01' = {
  name: clusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: clusterName
    agentPoolProfiles: [
      {
        name: 'defaultpool'
        count: agentCount
        vmSize: 'Standard_DS2_v2'
        osType: 'Linux'
        mode: 'System'
        vnetSubnetID: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, kubernetesSubnetName)
      }
    ]
   /*disable-next-line networkProfile: {
   /*disable-next-line   networkPlugin: 'azure'
   /*disable-next-line   networkPluginMode: 'overlay'
   /*disable-next-line   networkPolicy: 'azure'
   /*disable-next-line   podCidr: '10.244.0.0/16'
   /*disable-next-line   serviceCidr: '10.0.0.0/16'
   /*disable-next-line   dnsServiceIP: '10.0.0.10'
   /*disable-next-line }*/
   
    aadProfile: {
      enableAzureRBAC: true
      managed: true
    }
    apiServerAccessProfile: {
      authorizedIPRanges: companyAuthorizedIPs
    }
    linuxProfile: {
        adminUsername: linuxAdminUsername
        ssh: {
            publicKeys: [
                    {
                      keyData: sshRSAPublicKey
                    }
                
            ]
        }
    }
  }
}
       
  output controlPlaneFQDN string = aks.properties.fqdn
