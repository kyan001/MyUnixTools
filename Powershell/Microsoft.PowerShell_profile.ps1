# Utility functions for Powershell
function Echo-Message {  # Print message with different styles
    param (
        [switch]$Err,
        [switch]$Warn,
        [switch]$Info,
        [switch]$Debug,
        [switch]$Title,
        [switch]$Command,
        [string]$Message
    )
    $Underline = [char]27 + "[4m"  # "`e[4m"
    $Dim = [char]27 + "[2m"  # "`e[2m"
    $Reset = [char]27 + "[0m"  # "`e[0m"
    if ($Err) {
        Write-Host "${Dim}[${Reset}${Underline}Error${Reset}${Dim}]${Reset} ${Message}"
    } elseif ($Warn) {
        Write-Host "${Dim}[${Reset}Warning${Dim}]${Reset} ${Message}"
    } elseif ($Info) {
        Write-Host "${Dim}[Info]${Reset} ${Message}"
    } elseif ($Debug) {
        Write-Host "[Debug] ${Message}"
    } elseif ($Title) {
        Write-Host ""
        if ($Host.UI.SupportsVirtualTerminal) {  # Check if the host supports virtual terminal (ANSI and Unicode)
            $HorizontalBar = (New-Object string ([char]0x2550), $Message.Length)  # "═" * $Message.Length
            $VerticalBar = [char]0x2551  # "║"
            $TopLeft = [char]0x2554 + [char]0x2550  # "╔═"
            $TopRight = [char]0x2550 + [char]0x2557  # "═╗"
            $ButtomLeft = [char]0x255A + [char]0x2550  # "╚═"
            $ButtomRight = [char]0x2550 + [char]0x255D  # "═╝"
        } else {
            $HorizontalBar = "=" * $Message.Length
            $VerticalBar = "|"
            $TopLeft = "+="
            $TopRight = "=+"
            $ButtomLeft = "+="
            $ButtomRight = "=+"
        }
        Write-Host "${Dim}${TopLeft}${HorizontalBar}${TopRight}${Reset}"
        Write-Host "${Dim}${VerticalBar}${Reset} ${Message} ${Dim}${VerticalBar}${Reset}"
        Write-Host "${Dim}${ButtomLeft}${HorizontalBar}${ButtomRight}${Reset}"
    } elseif ($Command) {
        Write-Host "${Dim}>_${Reset} ${Underline}${Message}${Reset}"
    } else {
        Write-Host "${Message}"
    }
}

function Run-Verbose([string]$Command) {  # Print command before running it
    Echo-Message -Command "$Command"
    Invoke-Expression $Command
}

function Has-Command([switch]$Verbose, [string]$Command) {  # Check if a command exists
    # Usage: if (Has-Command "cmd") { ... }
    # Usage: if (Has-Command -Verbose "cmd" ) {... }
    if (Get-Command $Command -ErrorAction SilentlyContinue) {
        return $true
    } else {
        if ($Verbose) {
            Echo-Message -Err "Command not found: $Command"
        }
        return $false
    }
}

# Activate Starship prompt
if (Has-Command starship) {
    Invoke-Expression (&starship init powershell)
}

# Init Zoxide (z and zi)
if (Has-Command zoxide) {
    #$env:_ZO_FZF_OPTS = "--preview 'bat --color=always --line-range=:100 {}' --preview-window up"  # Set fzf options for Zoxide
    Invoke-Expression (& { (zoxide init powershell | Out-String) })  # Init Zoxide
}

# Add Python3 Scripts to PATH
if (Has-Command python3) {
    $env:PATH = (Get-Item $(python3 -m site --user-site)).parent.FullName + "\\Scripts" + ";$env:PATH"
}

function proxy {  # Toggle using proxy
    $proxy_addr = "http://127.0.0.1:1088"
    if (!$env:ALL_PROXY -and !$env:HTTPS_PROXY -and !$env:HTTP_PROXY) {
        $env:ALL_PROXY = $proxy_addr
        $env:HTTPS_PROXY = $proxy_addr
        $env:HTTP_PROXY = $proxy_addr
        Echo-Message -Info "[Proxy ON] ALL_PROXY, HTTPS_PROXY, HTTP_PROXY = $proxy_addr"
    } else {
        $UnsetList = @()
        if ($env:ALL_PROXY) {
            Remove-Item Env:\ALL_PROXY
            $UnsetList += "ALL_PROXY"
        }
        if ($env:HTTP_PROXY) {
            Remove-Item Env:\HTTP_PROXY
            $UnsetList += "HTTP_PROXY"
        }
        if ($env:HTTPS_PROXY) {
            Remove-Item Env:\HTTPS_PROXY
            $UnsetList += "HTTPS_PROXY"
        }
        Echo-Message -Info "[Proxy OFF] " + ($UnsetList -join ", ") + " = unset"
    }
}

function fzfcd {  # Use fzf to select a file, and cd to its directory
    if (Has-Command -Verbose fzf) {
        Set-Location (fzf --preview 'bat --color=always --line-range=:100 {}' --preview-window up | Split-Path -Parent)
    }
}

function up {  # Upgrade packages in package managers, or update packages.
    param (
        [switch]$All,  # `up -All` to run all upgrades and updates
        [switch]$Help,  # `up -Help` to show help message
        [switch]$List,  # `up -List` to list all supported packages and package managers
        [string[]]$Targets = @()  # `up pipx scoop` to run pipx and scoop upgrades only
    )
    function Upgrade-Pipx {  # Upgrade pipx's packages
        Echo-Message -Title 'Upgrade Pipx Packages'
        if (Has-Command -Verbose pipx) {  # Return if pipx not found
            Run-Verbose "pipx upgrade-all"  # 20s
        }
    }
    function Upgrade-Scoop {  # Upgrade scoop's packages
        Echo-Message -Title 'Upgrade Scoop Packages'
        if (Has-Command -Verbose scoop) {  # Return if scoop not found
            Run-Verbose "scoop update *"  # 10+ s
            Run-Verbose "scoop cleanup *"  # 300+ ms
            Run-Verbose "scoop cache rm *"  # ~100 ms
        }
    }
    function Upgrade-Winget {
        Echo-Message -Title 'Upgrade Winget Packages'
        if (Has-Command -Verbose winget) {  # Return if winget not found
            Echo-Message -Command "winget upgrade --all --accept-package-agreements --accept-source-agreements"
            Start-Process winget -ArgumentList @('upgrade', '--all', '--accept-package-agreements', '--accept-source-agreements') -NoNewWindow -Wait  # Avoid output clutter
        }
    }
    function Update-Rust {
        Echo-Message -Title 'Update Rust'
        if (Has-Command -Verbose rustup) {  # Return if rust not found
            Run-Verbose "rustup update"
        }
    }
    function Update-Pip {  # Update pip itself
        Echo-Message -Title 'Update pip'
        if (Has-Command -Verbose python3) {  # Return if pip not found
            Run-Verbose "python3 -m pip install --upgrade pip"  # 3s
        }
    }
    function Update-DotNet {
        Echo-Message -Title 'Update Windows Desktop Runtime (.NET)'
        if (Has-Command -Verbose scoop) {
            Run-Verbose "sudo scoop update windowsdesktop-runtime"
        }
    }
    function Update-Clash {
        Echo-Message -Title 'Update Clash Verge Rev'
        if (Has-Command -Verbose scoop) {
            Run-Verbose "scoop download clash-verge-rev"
            Run-Verbose "sudo scoop update clash-verge-rev"
        }
    }
    $Upgrades = @{
        'pipx' = { Upgrade-Pipx }
        'scoop' = { Upgrade-Scoop }
        'winget' = { Upgrade-Winget }
    }
    $Updates = @{
        'pip' = { Update-Pip }
        'rust' = { Update-Rust }
        'dotnet' = { Update-DotNet }
        'clash' = { Update-Clash }
    }
    $PrintList = {
        Echo-Message -Info "Supported Packages and Managers:`n`t$(@($Upgrades.Keys + $Updates.Keys) -join ', ')"
    }
    if ($All) {  # Run 'up -All' to run all upgrades and updates
        foreach ($Func in $Upgrades.Values) {
            $Func.Invoke()
        }
        foreach ($Func in $Updates.Values) {
            $Func.Invoke()
        }
    }
    if ($List) {  # Run 'up -List' or 'up -Help' to list all supported packages and package managers
        $PrintList.Invoke()
        return
    }
    if ($Help) {  # Run 'up -Help' to show detailed help message
        Echo-Message -Title "Help for 'up' Command"
        Echo-Message -Info "Usage: up [-All] [-List] [-Help] [Targets...]"
        Echo-Message -Info "Options:"
        Echo-Message -Info "    -All     Run all upgrades and updates."
        Echo-Message -Info "    -List    List all supported package managers and update targets."
        Echo-Message -Info "    -Help    Show this help message."
        Echo-Message -Info "Targets:"
        Echo-Message -Info "    Specify one or more targets to upgrade or update (e.g., 'pipx', 'rust')."
        $PrintList.Invoke()
        return
    }
    if ($Targets.Count -eq 0) {  # Run 'up' to run all upgrades, but not updates.
        foreach ($Func in $Upgrades.Values) {
            $Func.Invoke()
        }
    } else {
        foreach ($target in $Targets) {
            if ($Upgrades.ContainsKey($target)) {  # $target is in $Upgrades
                $Upgrades[$target].Invoke()
            } elseif ($Updates.ContainsKey($target)) {  # $target is in $Updates
                $Updates[$target].Invoke()
            } else {
                Echo-Message -Err "Unknown package manager: $target"
                $PrintList.Invoke()
            }
        }
    }
}

function venv {  # Deactivate if in a venv, or activate .venv\Scripts\activate
    $requirements = @("requirements.txt", "requirements-dev.txt", "requirements-opt.txt")
    # If venv is activated, deactivate it.
    if ($env:VIRTUAL_ENV) {
        Run-Verbose "deactivate"
        return
    }
    # If uv is not installed, return
    if (-not (Has-Command -Verbose uv)) {
        return $false
    }
    # If .venv\ not exists, create venv and relaunch the function.
    if (-not (Test-Path ".\.venv")) {
        Run-Verbose "uv venv"
        venv
        return
    }
    # If .venv\ exists, but not executable, recreate venv and relaunch the function.
    if (-not (Test-Path ".\.venv\Scripts\python.exe")) {
        Run-Verbose "Remove-Item -Recurse .\.venv"
        venv
        return
    }
    # If .venv\ exists, but version is old, recreate the.venv\
    try {
        & .\.venv\Scripts\python.exe --version > $null 2>&1
    } catch {
        Run-Verbose "Remove-Item -Recurse .\.venv"
        venv
        return
    }
    # If .venv\ exists, and python is executable, update it and activate
    foreach ($file in $requirements) {
        if (Test-Path ".\$file") {
            Run-Verbose "uv pip install --refresh -r .\$file"
        }
    }
    # If .venv\bin\ not exists, create a symlink for it to .venv\Scripts\
    if (-not (Test-Path "${PWD}\.venv\bin")) {
        Run-Verbose "cmd /c mklink /D `"${PWD}\.venv\bin`" `"${PWD}\.venv\Scripts`""  # Create a symlink for 'bin' to 'Scripts' in .venv\
    }
    # Activate the venv
    Run-Verbose ".\.venv\Scripts\activate"
}

# Main
proxy
