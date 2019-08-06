Connect-AzAccount

##############################################################################################
# Declaire you infra here by chnaging or adding variebles
# Not necesary that all veriables will be used.

    $ResourceGroup = RG-BreakMe1
    $Location = WestUS
    $StorageAccount = storageaccountbreakme1
    
    $Internal.vNet1 = vnet-internal-1
    $Internal.vNet2 = vnet-internal-2

    $SubNetMusk1 = snm-internal-1
    $SubNetMusk2 = snm-internal-2

#############################################################################################
    # Create a resource group
    New-AzResourceGroup -Name $resourceGroup -Location $location
    
    # Create a Storage Account
    New-AzStorageAccount -ResourceGroupName $ResourceGroup -Name $StorageAccount -Location $Location -SkuName Standard_LRS -Kind StorageV2

    # Create a subnet configuration
    $SubnetConfig1 = New-AzVirtualNetworkSubnetConfig -Name $SubNetMusk1 -AddressPrefix 192.168.1.0/25
    $SubnetConfig2 = New-AzVirtualNetworkSubnetConfig -Name $SubNetMusk2 -AddressPrefix 192.168.1.128/26
    
    # Create a virtual network
    $VNet = New-AzVirtualNetwork -ResourceGroupName $resourceGroup -Location $location -Name $Internal.vNet1 -AddressPrefix 192.168.1.0/24 -Subnet $subnetConfig1, $subnetConfig2
    
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

#############################################################################################
# Copy and Paste the following section for multiple VM with similar configuration.
# Only change the VMName veriable in every paste.
# Followings are 2 examples of GUI and Core Windows Versions

    # Creating First VM
    $VMSize = "Standard_B1Ls"
    $VMName = "Gui-Win19-1"
    $NICName = "VMName"+"-NIC"

    $PubIP = New-AzPublicIpAddress -ResourceGroupName $ResourceGroup -Location $Location -Name "BreakMe1-Cor-Win19-JumpDNS$(Get-Random)" -AllocationMethod Static -IdleTimeoutInMinutes 4
    $NIC = New-AzNetworkInterface -Name $NICName -ResourceGroupName $ResourceGroup -Location $Location -SubnetID $SubnetID2 -PublicIpAddressId $PubIP.Id -NetworkSecurityGroupId $nsg.Id

    $VirtualMachine = New-AzVMConfig -VMName $VMName -VMSize $VMSize
    $VirtualMachine = Set-AzVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VMname -Credential $Credential -ProvisionVMAgent -EnableAutoUpdate
    $VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine -Id $NIC.Id
    $VirtualMachine = Set-AzVMSourceImage -VM $VirtualMachine -PublisherName 'MicrosoftWindowsServer' -Offer 'WindowsServer' -Skus '2019-Datacenter' -Version latest

    New-AzVM -ResourceGroupName $ResourceGroup -Location $Location -VM $VirtualMachine -Verbose

    # Creating Second VM
    $VMSize = "Standard_B1Ls"
    $VMName = "Cor-Win19-2"
    $NICName = "VMName"+"-NIC"

    $PubIP = New-AzPublicIpAddress -ResourceGroupName $ResourceGroup -Location $Location -Name "BreakMe1-Cor-Win19-JumpDNS$(Get-Random)" -AllocationMethod Static -IdleTimeoutInMinutes 4
    $NIC = New-AzNetworkInterface -Name $NICName -ResourceGroupName $ResourceGroup -Location $Location -SubnetID $SubnetID2 -PublicIpAddressId $PubIP.Id -NetworkSecurityGroupId $nsg.Id

    $VirtualMachine = New-AzVMConfig -VMName $VMName -VMSize $VMSize
    $VirtualMachine = Set-AzVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VMname -Credential $Credential -ProvisionVMAgent -EnableAutoUpdate
    $VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine -Id $NIC.Id
    $VirtualMachine = Set-AzVMSourceImage -VM $VirtualMachine -PublisherName 'MicrosoftWindowsServer' -Offer 'WindowsServer' -Skus '2019-Datacenter-Core' -Version latest

    New-AzVM -ResourceGroupName $ResourceGroup -Location $Location -VM $VirtualMachine -Verbose

#############################################################################################