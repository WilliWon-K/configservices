# Get the firewall configuration for all firewall profiles
$firewallConfig = & netsh advfirewall show all

# Split the output into lines
$lines = $firewallConfig -split '\r?\n'

# Initialize variables
$currentProfile = $null
$firewallProfiles = @()
$xml=""

# Define the attribute names based on the language
$attributeState = ""
$attributeFireWallPolicy = ""
$attributeParam = ""

# Detect language based on the first line of the output
$language = if ($lines[1] -match '^(Domain|Private|Public) Profile Settings:') { 'English' } else { 'French' }

if ($language -eq 'French') {
    $attributeState = 'État'
    $attributeFireWallPolicy = 'Stratégie de pare-feu'
    $attributeParam = 'Paramètres'
} elseif ($language -eq 'English') {
    $attributeState = 'State'
    $attributeFireWallPolicy = 'Firewall Policy'
    $attributeParam = 'Settings'
 
}

foreach ($line in $lines) {
    if ($line -match 'profil') {
        # If there's a current profile being processed, add it to the list
        if ($null -ne $currentProfile) {
            $firewallProfiles += $currentProfile
            $currentProfile = $null
        }
        $currentProfile = New-Object PSObject
        $line = $line.Replace(":", "").Trim() 
        $currentProfile | Add-Member -MemberType NoteProperty -Name "Profile" -Value $line.Replace($attributeParam, "").Trim() 
    } elseif ($line -match '^\S') {
        # Line contains a property
        if ($null -ne $currentProfile) {
            
            $parts = $line -split '\s{2,}', 2
            if ($parts.Count -eq 2) {
                $propertyName = $parts[0].Trim()
                $propertyValue = $parts[1].Trim()
                $currentProfile | Add-Member -MemberType NoteProperty -Name $propertyName -Value $propertyValue
            }
        }
    }
}

# Add the last profile if there is one
if ($null -ne $currentProfile) {
    $firewallProfiles += $currentProfile
}

# Output the profiles
foreach($firewallProfile in $firewallProfiles)
{
    $xml += "<FIREWALLCONFIG>`n"
    $xml += "<PROFILE>" + $firewallProfile.Profile + "</PROFILE>`n"
    $xml += "<STATE>" + $firewallProfile.$attributeState + "</STATE>`n"
    $xml += "<FIREWALLPOLICY>" + $firewallProfile.$attributeFireWallPolicy + "</FIREWALLPOLICY>`n"
    $xml += "<LOCALFIREWALLRULES>" + $firewallProfile.LocalFirewallRules + "</LOCALFIREWALLRULES>`n"
    $xml += "<FILENAME>" + $firewallProfile.FileName + "</FILENAME>`n"
    $xml += "<MAXFILESIZE>" + $firewallProfile.MaxFileSize + "</MAXFILESIZE>`n"
    $xml += "</FIREWALLCONFIG>`n"
}

if($xml -eq "") {
	$xml = "<FIREWALLCONFIG />"
}

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::WriteLine($xml)

