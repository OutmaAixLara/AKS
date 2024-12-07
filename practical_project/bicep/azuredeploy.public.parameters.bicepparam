using './azuredeploy.bicep'

param aksClusterEnablePrivateCluster = false

param aksClusterNetworkPlugin = 'azure'

param aksClusterNetworkPolicy = 'azure'

param aksClusterPodCidr = '10.244.0.0/16'

param aksClusterServiceCidr = '10.0.0.0/16'

param aksClusterDnsServiceIP = '10.0.0.10'

param aksClusterOutboundType = 'userAssignedNATGateway'

param aksClusterAdminUsername = 'ubuntu'

param aksClusterSshPublicKey = '<SSH-KEY>'

param aadProfileManaged = true

param aadProfileEnableAzureRBAC = true

param aadProfileAdminGroupObjectIDs = [
  '<OBJECT-ID-OF-AAD-ADMIN-GROUP>'
]

param podIdentityProfileEnabled = true

param systemNodePoolName = 'system'

param systemNodePoolVmSize = 'Standard_DS3_v2'

//param systemNodePoolAgentCount = 1

param systemNodePoolMaxCount = 5

param systemNodePoolMinCount = 3

param systemNodePoolNodeTaints = [
  'CriticalAddonsOnly=true:NoSchedule'
]

param userNodePoolName = 'user'

param userNodePoolVmSize = 'Standard_DS3_v2'

param userNodePoolAgentCount = 3

param userNodePoolMaxCount = 5

param userNodePoolMinCount = 3

param virtualNetworkAddressPrefixes = '192.168.0.0/20'

param aksSubnetName = 'AksSubnet'

param aksSubnetAddressPrefix = '192.168.8.0/24'

param podSubnetName = 'PodSubnet'

param podSubnetAddressPrefix = '192.168.9.0/24'

param vmSubnetName = 'managementSubnet'

param vmSubnetAddressPrefix = '192.168.0.0/24'

//param bastionSubnetAddressPrefix = '/24'

param applicationGatewaySubnetName = 'ApplicationGatewaySubnet'

param applicationGatewaySubnetAddressPrefix = '10.16.0.0/24'

//param logAnalyticsSku = 'PerGB2018'

//param logAnalyticsRetentionInDays = 60

param vmSize = 'Standard_F4s_v2'

param imagePublisher = 'Canonical'

param imageOffer = '0001-com-ubuntu-server-focal-daily'

param imageSku = '22_04-daily-lts-gen2'

param authenticationType = 'password'

param vmAdminUsername = 'ubuntu'

param vmAdminPasswordOrKey = 'Password123!?'

param diskStorageAccounType = 'Standard_LRS'

param osDiskSize = 30

