<powershell>
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

winget install -e --id Mozilla.Firefox

winget install -e --id Git.Git

winget install -e --id GitHub.GitHubDesktop

winget install -e --id Google.Chrome

winget install -e --id VSCodium.VSCodium


git clone https://github.com/GuyBarros/ad-lab C:\ad-lab

</powershell>
