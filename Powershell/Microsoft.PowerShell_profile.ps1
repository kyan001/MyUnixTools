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
    $Underline = "`e[4m"
    $Dim = "`e[2m"
    $Reset = "`e[0m"
    if ($Err) {
        Write-Output "${Dim}[${Reset}${Underline}Error${Reset}${Dim}]${Reset} ${Message}"
    } elseif ($Warn) {
        Write-Output "${Dim}[${Reset}Warning${Dim}]${Reset} ${Message}"
    } elseif ($Info) {
        Write-Output "${Dim}[Info]${Reset} ${Message}"
    } elseif ($Debug) {
        Write-Output "[Debug] ${Message}"
    } elseif ($Title) {
        Write-Output ""
        if ((& {Write-Output "═║╔╗╚╝"}) -eq "═║╔╗╚╝") {
            $HorizontalBar = "═" * $Message.Length
            $VerticalBar = "║"
            $TopLeft = "╔═"
            $TopRight = "═╗"
            $ButtomLeft = "╚═"
            $ButtomRight = "═╝"
        } else {
            $HorizontalBar = "=" * $Message.Length
            $VerticalBar = "|"
            $TopLeft = "+="
            $TopRight = "=+"
            $ButtomLeft = "+="
            $ButtomRight = "=+"
        }
        Write-Output "${Dim}${TopLeft}${HorizontalBar}${TopRight}${Reset}"
        Write-Output "${Dim}${VerticalBar}${Reset} ${Message} ${Dim}${VerticalBar}${Reset}"
        Write-Output "${Dim}${ButtomLeft}${HorizontalBar}${ButtomRight}${Reset}"
    } elseif ($Command) {
        Write-Output "${Dim}>_${Reset} ${Underline}${Message}${Reset}"
    } else {
        Write-Output "${Message}"
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
        Echo-Message -Info "[Proxy ON] ALL_PROXY, HTTPS_PROXY and HTTP_PROXY set to $proxy_addr. Use 'Proxy' to turn off."
    } else {
        if ($env:ALL_PROXY) {
            Remove-Item Env:\ALL_PROXY
            Echo-Message -Info "[Proxy OFF] ALL_PROXY unset from $env:ALL_PROXY."
        }
        if ($env:HTTP_PROXY) {
            Remove-Item Env:\HTTP_PROXY
            Echo-Message -Info "[Proxy OFF] HTTP_PROXY unset."
        }
        if ($env:HTTPS_PROXY) {
            Remove-Item Env:\HTTPS_PROXY
            Echo-Message -Info "[Proxy OFF] HTTPS_PROXY unset."
        }
    }
}

function fzfcd {  # Use fzf to select a file, and cd to its directory
    if (Has-Command -Verbose fzf) {
        Set-Location (fzf --preview 'bat --color=always --line-range=:100 {}' --preview-window up | Split-Path -Parent)
    }
}

function up {  # Upgrade pip/pipx/scoop, and pipx/scoop packages.
    function Upgrade-Pipx {  # Upgrade pipx's packages
        Echo-Message -Title 'Upgrade Pipx Packages'
        Has-Command -Verbose pipx || return  # Return if pipx not found
        Run-Verbose "pipx upgrade-all"  # 20s
    }
    function Update-Pip {  # Update pip itself
        Echo-Message -Title 'Update pip'
        Has-Command -Verbose pip || return  # Return if pip not found
        Run-Verbose "python3 -m pip install --upgrade pip"  # 3s
    }
    function Upgrade-Scoop {  # Upgrade scoop's packages
        Echo-Message -Title 'Upgrade Scoop Packages'
        Has-Command -Verbose scoop || return $false  # Return if scoop not found
        Run-Verbose "scoop update *"  # 10+ s
        Run-Verbose "scoop cleanup *"  # 300+ ms
        Run-Verbose "scoop cache rm *"  # ~100 ms
    }
    function Upgrade-Winget {
        Echo-Message -Title 'Upgrade Winget Packages'
        Has-Command -Verbose winget || return $false  # Return if winget not found
        Run-Verbose "winget install --id Microsoft.Powershell --source winget"
    }
    function Upgrade-Rust {
        Echo-Message -Title 'Update Rust'
        Has-Command -Verbose winget || return $false  # Return if rust not found
        Run-Verbose "rustup update"
    }
    $upgrades = @('pipx', 'scoop', 'winget')  # Available package managers for upgrades
    $updates = @('pip' 'rust')  # Available package managers to updates
    if ($args.Count -eq 0) {  # Run 'up' to run all upgrades.
        foreach ($pm in $upgrades) {
            $pmCapitalized = $pm.Substring(0, 1).ToUpper() + $pm.Substring(1)
            Invoke-Expression "Upgrade-$pmCapitalized"
        }
        foreach ($pm in $updates) {
            $pmCapitalized = $pm.Substring(0, 1).ToUpper() + $pm.Substring(1)
            Invoke-Expression "Update-$pmCapitalized"
        }
    } else {  # Run 'up pip scoop' for scoop and pip upgrades only.
        foreach ($arg in $args) {
            if ($upgrades -contains $arg) {  # $arg is in $upgrades
                $argCapitalized = $arg.Substring(0, 1).ToUpper() + $arg.Substring(1)
                Invoke-Expression "Upgrade-$argCapitalized"
            } elseif ($updates -contains $arg) {  # $arg is in $updates
                $argCapitalized = $arg.Substring(0, 1).ToUpper() + $arg.Substring(1)
                Invoke-Expression "Update-$argCapitalized"
            } else {
                Echo-Message -Err "Unknown package manager: $arg"
                Echo-Message -Info "Supported package managers: $(($upgrades + $updates) -join ' ')"
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
    Has-Command -Verbose uv || return $false
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
