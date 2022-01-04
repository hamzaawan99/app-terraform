

data "aws_security_group" "webdmz" {
    filter {
      name = "tag:Name"
      values = ["WebDMZ"]
    }
}


# resource "aws_network_interface" "eni" {
#     subnet_id = data.aws_subnet.ex_subnet.id
#     security_groups = [data.aws_security_group.webdmz.id]
#     tags = {
#         Name = "Terraform New"
#     }
# }

resource "aws_instance" "machine" {
  ami = "ami-0d80714a054d3360c"
  instance_type = "t2.micro"
  key_name = "EC2-NVirginia-KP"

  # this works for default VPC subnets
  #security_groups = [data.aws_security_group.webdmz.id]

  # If vpc_security_group_ids is used with a non-default security group 
  # then there will be a conflict because it will take a default subnet
  # so subnet_id is must if security group is non-default
  # Alternate way is to create a new ENI like below (commented now)
  #subnet_id = data.aws_subnet.ex_subnet.id
  vpc_security_group_ids = [data.aws_security_group.webdmz.id]
  user_data = "${file("notepad.txt")}"
  /*user_data = <<-EOF
    <powershell>
	  #Enabling the PowerShell IIS"
    Get-WindowsOptionalFeature -Online | Where-Object {$_.FeatureName -like "IIS*"} | Format-Table
    Enable-WindowsOptionalFeature -Online -FeatureName "IIS-DefaultDocument" -All
    #Downloading the Notepad++ using Powershell and Installing"
    # Set TLS support for Powershell and parse the JSON request
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $npp = Invoke-WebRequest -UseBasicParsing 'https://api.github.com/repos/notepad-plus-plus/notepad-plus-plus/releases/latest' | ConvertFrom-Json
    # Get the download URL from the JSON object
    $dlUrl = $npp.assets[2].browser_download_url
    # Get the file name
    $outfile = $npp.assets[2].name
    # Get the current directory and build the installer path
    $cwd = (Get-Location).Path
    $installerPath = Join-Path $cwd $outfile
    Write-Host "Silently Installing $($npp.name)... Please wait..."
    # Start the download and save the file to the installerpath
    Invoke-WebRequest -UseBasicParsing $dlUrl -OutFile $installerPath
    # Silently install NotepadPlusPlus then remove the downloaded item
    Start-Process -FilePath $installerPath -Args "/S" -Verb RunAs -Wait
    Remove-Item $installerPath
    #Downloading and installing NetFramework 3.5 & lower
    Install-WindowsFeature NET-Framework-Features
    </powershell>
  EOF*/
  tags = {
    "Name" = "PowerShell Test"
  }

  # network_interface {
  #   network_interface_id = data.aws_network_interface.eni.id
  #   device_index = 0
  # }

  
}