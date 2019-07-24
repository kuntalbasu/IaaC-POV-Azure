# Creating Resource Group, Storage Account, VNet, Subnets, NSG Rule, User Account and Password

    Connect-AzAccount

    # Variables for common values
    $ResourceGroup = "RG-BreakMe1"
    $Location = "WestUS"
    $StorageAccount = "storageaccountbreakme1"
    
    # Create a resource group
    New-AzResourceGroup -Name $resourceGroup -Location $location
    
    # Create a Storage Account
    New-AzStorageAccount -ResourceGroupName $ResourceGroup -Name $StorageAccount -Location $Location -SkuName Standard_LRS -Kind StorageV2

    # Create a subnet configuration
    $SubnetConfig1 = New-AzVirtualNetworkSubnetConfig -Name snm-internal-1 -AddressPrefix 192.168.1.0/25
    $SubnetConfig2 = New-AzVirtualNetworkSubnetConfig -Name snm-internal-2 -AddressPrefix 192.168.1.128/26
    
    # Create a virtual network
    $VNet = New-AzVirtualNetwork -ResourceGroupName $resourceGroup -Location $location -Name vnet-internal-1 -AddressPrefix 192.168.1.0/24 -Subnet $subnetConfig1, $subnetConfig2
    
     $SubnetID1 = $vnet.Subnets[0].Id
     $SubnetID2 = $vnet.Subnets[1].Id

     # Creating NSG Rule
    $NSGRuleRDP = New-AzNetworkSecurityRuleConfig -Name BreakMe1NetworkSecurityGroupRuleRDP  -Protocol Tcp `
    -Direction Inbound -Priority 1000 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * `
    -DestinationPortRange 3389 -Access Allow

    # Create a network security group
    $NSG = New-AzNetworkSecurityGroup -ResourceGroupName $ResourceGroup -Location $Location `
    -Name BreakMe1NetworkSecurityGroup -SecurityRules $NSGRuleRDP

     $VMLocalAdminUser = "LocalAdminUser"
     $VMLocalAdminSecurePassword = ConvertTo-SecureString Rit_123456789 -AsPlainText -Force
     $Credential = New-Object System.Management.Automation.PSCredential ($VMLocalAdminUser, $VMLocalAdminSecurePassword);

#################################################################################################################################################
# Creating BreakMe1-GUI-Win19-Jump

$ComputerName = "Gui-Win19-Jump"
$VMName = "Gui-Win19-Jump"
$NICName = "Gui-Win19-Jump-NIC"
$VMSize = "Standard_B1s"

$PubIP = New-AzPublicIpAddress -ResourceGroupName $ResourceGroup -Location $Location -Name "BreakMe1-Cor-Win19-JumpDNS$(Get-Random)" -AllocationMethod Static -IdleTimeoutInMinutes 4
$NIC = New-AzNetworkInterface -Name $NICName -ResourceGroupName $ResourceGroup -Location $Location -SubnetID $SubnetID2 -PublicIpAddressId $PubIP.Id -NetworkSecurityGroupId $nsg.Id

$VirtualMachine = New-AzVMConfig -VMName $VMName -VMSize $VMSize
$VirtualMachine = Set-AzVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $ComputerName -Credential $Credential -ProvisionVMAgent -EnableAutoUpdate
$VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine -Id $NIC.Id
$VirtualMachine = Set-AzVMSourceImage -VM $VirtualMachine -PublisherName 'MicrosoftWindowsServer' -Offer 'WindowsServer' -Skus '2019-Datacenter' -Version latest

New-AzVM -ResourceGroupName $ResourceGroup -Location $Location -VM $VirtualMachine -Verbose

#################################################################################################################################################
# Creating BreakMe1-Cor-Win19-ADC1

$ComputerName = "Cor-Win19-ADC1"
$VMName = "Cor-Win19-ADC1"
$NICName = "Cor-Win19-ADC1-NIC"
$VMSize = "Standard_B1ms"
 
$PriIP = 192.168.1.11
$NIC = New-AzNetworkInterface -Name $NICName -ResourceGroupName $ResourceGroup -Location $Location -SubnetID $SubnetID1 -PrivateIpAddress $PriIP -NetworkSecurityGroupId $NSG.Id 
     
$VirtualMachine = New-AzVMConfig -VMName $VMName -VMSize $VMSize
$VirtualMachine = Set-AzVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $ComputerName -Credential $Credential -ProvisionVMAgent -EnableAutoUpdate
$VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine -Id $NIC.Id
$VirtualMachine = Set-AzVMSourceImage -VM $VirtualMachine -PublisherName 'MicrosoftWindowsServer' -Offer 'WindowsServer' -Skus '2019-Datacenter-Core' -Version latest
     
New-AzVM -ResourceGroupName $ResourceGroup -Location $Location -VM $VirtualMachine -Verbose

#################################################################################################################################################
# Creating BreakMe1-GUI-Win19-MNG1

$ComputerName = "Gui-Win19-MNG1"
$VMName = "Gui-Win19-MNG1"
$NICName = "Gui-Win19-MNG1-NIC"
$VMSize = "Standard_B1ms"

$PriIP = 192.168.1.12
$NIC = New-AzNetworkInterface -Name $NICName -ResourceGroupName $ResourceGroup -Location $Location -SubnetID $SubnetID1 -PrivateIpAddress $PriIP -NetworkSecurityGroupId $NSG.Id 

$VirtualMachine = New-AzVMConfig -VMName $VMName -VMSize $VMSize
$VirtualMachine = Set-AzVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $ComputerName -Credential $Credential -ProvisionVMAgent -EnableAutoUpdate
$VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine -Id $NIC.Id
$VirtualMachine = Set-AzVMSourceImage -VM $VirtualMachine -PublisherName 'MicrosoftWindowsServer' -Offer 'WindowsServer' -Skus '2019-Datacenter' -Version latest

New-AzVM -ResourceGroupName $ResourceGroup -Location $Location -VM $VirtualMachine -Verbose

#################################################################################################################################################
# Creating BreakMe1-Cor-Win19-SQL1

$ComputerName = "Cor-Win19-SQL1"
$VMName = "Cor-Win19-SQL1"
$NICName = "Cor-Win19-SQL1-NIC"
$VMSize = "Standard_B1ms"

$PriIP = 192.168.1.13
$NIC = New-AzNetworkInterface -Name $NICName -ResourceGroupName $ResourceGroup -Location $Location -SubnetID $SubnetID1 -PrivateIpAddress $PriIP -NetworkSecurityGroupId $NSG.Id 

$VirtualMachine = New-AzVMConfig -VMName $VMName -VMSize $VMSize
$VirtualMachine = Set-AzVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $ComputerName -Credential $Credential -ProvisionVMAgent -EnableAutoUpdate
$VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine -Id $NIC.Id
$VirtualMachine = Set-AzVMSourceImage -VM $VirtualMachine -PublisherName 'MicrosoftWindowsServer' -Offer 'WindowsServer' -Skus '2019-Datacenter-Core' -Version latest

New-AzVM -ResourceGroupName $ResourceGroup -Location $Location -VM $VirtualMachine -Verbose

#################################################################################################################################################
# Creating BreakMe1-Cor-Win19-SQL2

$ComputerName = "Cor-Win19-SQL2"
$VMName = "Cor-Win19-SQL2"
$NICName = "Cor-Win19-SQL2-NIC"
$VMSize = "Standard_B1ms"

$PriIP = 192.168.1.14
$NIC = New-AzNetworkInterface -Name $NICName -ResourceGroupName $ResourceGroup -Location $Location -SubnetID $SubnetID1 -PrivateIpAddress $PriIP -NetworkSecurityGroupId $NSG.Id 

$VirtualMachine = New-AzVMConfig -VMName $VMName -VMSize $VMSize
$VirtualMachine = Set-AzVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $ComputerName -Credential $Credential -ProvisionVMAgent -EnableAutoUpdate
$VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine -Id $NIC.Id
$VirtualMachine = Set-AzVMSourceImage -VM $VirtualMachine -PublisherName 'MicrosoftWindowsServer' -Offer 'WindowsServer' -Skus '2019-Datacenter-Core' -Version latest

New-AzVM -ResourceGroupName $ResourceGroup -Location $Location -VM $VirtualMachine -Verbose

#################################################################################################################################################

