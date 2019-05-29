# Add-AzureRmAccount

$rgName="testtesttest"
$location="eastus2"

# Create a resource group.
New-AZResourceGroup -Name $rgName -Location $location

# Subnet configuration
$subnet1config = New-AZVirtualNetworkSubnetConfig -Name "mysubnet1" -AddressPrefix "10.3.1.0/24"
$subnet2config = New-AZVirtualNetworkSubnetConfig -Name "mysubnet2" -AddressPrefix "10.3.2.0/24"


# Create the VNet with the subnet configurations
$vnet = New-AZVirtualNetwork -ResourceGroupName $rgName -Name "myvnet" -AddressPrefix '10.3.0.0/16' -Location $location -Subnet $subnet1config, $subnet2config


# Create Public IP addresses for the virtual machines
$server1pubip = New-AzPublicIpAddress -ResourceGroupName $rgName -Name "server1-pubip" -location $location -AllocationMethod Dynamic 
$server2pubip = New-AzPublicIpAddress -ResourceGroupName $rgName -Name "server2-pubip" -location $location -AllocationMethod Dynamic
$server3pubip = New-AzPublicIpAddress -ResourceGroupName $rgName -Name "server3-pubip" -location $location -AllocationMethod Dynamic

# Create NICs for the virtual machines
$server1nic = New-AzNetworkInterface -ResourceGroupName $rgName -Location $location -Name "server1-nic"  -Subnet $vnet.Subnets[0] -PublicIpAddress $server1pubip -PrivateIpAddress "10.3.1.5"
$server2nic = New-AzNetworkInterface -ResourceGroupName $rgName -Location $location -Name "server2-nic"  -Subnet $vnet.Subnets[0] -PublicIpAddress $server2pubip -PrivateIpAddress "10.3.1.6"
$server3nic = New-AzNetworkInterface -ResourceGroupName $rgName -Location $location -Name "server3-nic"  -Subnet $vnet.Subnets[1] -PublicIpAddress $server3pubip -PrivateIpAddress "10.3.2.5"


############################################################################


# Acquire Server credentials
$servercred = Get-Credential -Message "Enter a username and password for the servers"

# Create Server 1, 2 & 3
$server1vmConfig = New-AzVMConfig -VMName "server1" -VMSize "Standard_DS2" | 
  Set-AzVMOperatingSystem -Windows -ComputerName "server1" -Credential $servercred | 
  Set-AzVMSourceImage -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2019-Datacenter" -Version latest | 
  Set-AzVMBootDiagnostics -Disable | Add-AzVMNetworkInterface -Id $server1nic.Id 

$server2vmConfig = New-AzVMConfig -VMName "server2" -VMSize "Standard_DS2" | 
  Set-AzVMOperatingSystem -Windows -ComputerName "server2" -Credential $servercred | 
  Set-AzVMSourceImage -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2019-Datacenter" -Version latest | 
  Set-AzVMBootDiagnostics -Disable | Add-AzVMNetworkInterface -Id $server2nic.Id 

$server3vmConfig = New-AzVMConfig -VMName "server3" -VMSize "Standard_DS2" | 
  Set-AzVMOperatingSystem -Windows -ComputerName "server3" -Credential $servercred | 
  Set-AzVMSourceImage -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2019-Datacenter" -Version latest | 
  Set-AzVMBootDiagnostics -Disable | Add-AzVMNetworkInterface -Id $server3nic.Id 



$server1vm = New-AzVM -ResourceGroupName $rgName -Location $location -VM $server1vmConfig 
$server2vm = New-AzVM -ResourceGroupName $rgName -Location $location -VM $server2vmConfig
$server3vm = New-AzVM -ResourceGroupName $rgName -Location $location -VM $server3vmConfig


# Remove Resource Group
# Remove-AzResourceGroup -Name $rgName


#############################################################
# Some helpful cmdlets 

## Get all resopurce groups in the Subscription
# Get-AzResourceGroup

## Get Azure VNet information
# Get-AzVirtualNetwork -ResourceGroupName rangervnetrg -Name myvnet

## Get all Azure Public IP Addresses
# Get-AzPublicIpAddress

## Get all Azure Network Interfaces 
# Get-AzNetworkInterface
