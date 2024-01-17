# Script d'installation "OpenSSH Server" pour Windows Server 2019
# Authentification par cle SSH publique
# Auteurs Pascal Sauliere et Pierre Chesne

 
$key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCm9OdKa3kFqUd7QlgytUnBTwKMmmwpK7FqsZu8qXX/HSSP1PlhyTLOo7oojv6uOxwmOZqnaNYt+QlxCCREBrtWUvoZUAcvXSQdDzcyFPSHQM3A2Rtnjyr+FSBZaeIiJapl5ujrTWyIZPnepLlJEjYbmTC0Ul8ti10kolxU9pGSKTdkHAKIzR9HeqWishFlF8S8039Mt+SUC/2p0OC3+J2mV2HL9ccPXyUE6ShOPAT04MGuUyNXEO6NgZGG7jFYsva5uz8wR7roih1hJu9icP0hiw8TT47LN7686zTi58zQfATd7pPpnNo46BnJ4e28d6aWyF96uav249H+w4I0Xhw5gFBufEgX1K8y3SjEY0ilzwd1gQdDABcbePWVDHj+njUhX2VcAIHBLJ4LRi5t6bupDCQzn6mAt2l7ZWgOtlBKBWjcAj886RCqKCz+is1rut0lJBh3dq0acWEzG42/k+IlwVCq88Ju5nvAbTdeX5bW8gpFIuhVxZwllfuxFCxxDuc="
$adminUsername = "pierrc"


# Installation OpenSSH Server
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0

# Demarage du serveur Open SSH
Start-Service sshd

# Demarage Automatique du server Open SSH
Set-Service -Name sshd -StartupType 'Automatic'

# Shell "PowerShell" par defaut
New-ItemProperty `
  -Path "HKLM:\SOFTWARE\OpenSSH" `
  -Name DefaultShell `
  -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" `
  -PropertyType String -Force

# Creation du repertoire .ssh
New-Item -Path c:\Users\$adminUsername\.ssh -ItemType Directory

# Copie de la cle publique
Add-Content c:\Users\$adminUsername\.ssh\authorized_keys $key

# Parametrage du fichier sshd_config
(Get-Content C:\ProgramData\ssh\sshd_config).Replace('#PubkeyAuthentication yes' , 'PubkeyAuthentication yes') | Set-Content C:\ProgramData\ssh\sshd_config
(Get-Content C:\ProgramData\ssh\sshd_config).Replace('AuthorizedKeysFile __PROGRAMDATA__/ssh/administrators_authorized_keys' , '#AuthorizedKeysFile __PROGRAMDATA__/ssh/administrators_authorized_keys') | Set-Content C:\ProgramData\ssh\sshd_config
(Get-Content C:\ProgramData\ssh\sshd_config).Replace('Match Group administrators' , '#Match Group administrators') | Set-Content C:\ProgramData\ssh\sshd_config

# Redemarrage du service OpenSSH
Restart-Service sshd