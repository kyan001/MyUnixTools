Invoke-Expression (&starship init powershell)
$env:PATH = (Get-Item $(python3 -m site --user-site)).parent.FullName + "\\Scripts" + ";$env:PATH"

function Echo-Message {
    param (
        [switch]$Err,
        [switch]$Warn,
        [switch]$Info,
        [switch]$Title,
        [switch]$Command,
        [string]$Message
    )
    $Underline = "`e[4m"
    $Dim = "`e[2m"
    $Reset = "`e[0m"
    if ($Err) {
        Write-Host "${Dim}[${Reset}${Underline}Error${Reset}${Dim}]${Reset} ${Message}"
    } elseif ($Warn) {
        Write-Warning "${Dim}[${Reset}Warning${Dim}]${Reset} ${Message}"
    } elseif ($Info) {
        Write-Host "${Dim}[Info]${Reset} ${Message}"
    } elseif ($Title) {
        Write-Host ""
        Write-Host "${Dim}============${Reset}"
        Write-Host "${Dim}|${Reset} ${Message}"
        Write-Host "${Dim}============${Reset}"
    } elseif ($Command) {
        Write-Host "${Dim}>_${Reset} ${Underline}${Message}${Reset}"
    } else {
        Write-Output "${Message}"
    }
}

function Run-Verbose([string]$Command) {
    Echo-Message --Command "$Command"
    Invoke-Expression $Command
}

function proxy {  # toggle using proxy
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

function fzfcd {
    Set-Location (fzf --preview 'bat --color=always --line-range=:100 {}' --preview-window up | Split-Path -Parent)
}

function up {  # upgrade pip/pipx/scoop, and pipx/scoop packages.
    function Upgrade-Pipx {
        Echo-Message -Title 'Upgrade Pipx Packages'
        Run-Verbose "pipx upgrade-all"  # 20s
    }
    function Upgrade-Pip {
        Echo-Message -Title 'Upgrade pip'
        Run-Verbose "python3 -m pip install --upgrade pip"  # 3s
    }
    function Upgrade-Scoop {
        Echo-Message -Title 'Upgrade Scoop Packages'
        Run-Verbose "scoop update *"  # 10+ s
        Run-Verbose "scoop cleanup *"  # 300+ ms
        Run-Verbose "scoop cache rm *"  # ~100 ms
    }

    $available_pms = @('pip', 'pipx', 'scoop')  # Available package managers
    if ($args.Count -eq 0) {  # Run 'up' to run all upgrades.
        foreach ($pm in $available_pms) {
            $pmCapitalized = $pm.Substring(0, 1).ToUpper() + $pm.Substring(1)
            Invoke-Expression "Upgrade_$pmCapitalized"
        }
    } else {  # Run 'up pip scoop' for scoop and pip upgrades only.
        foreach ($arg in $args) {
            if ($available_pms -contains $arg) {  # $arg is in available_pms
                $argCapitalized = $arg.Substring(0, 1).ToUpper() + $arg.Substring(1)
                Invoke-Expression "Upgrade_$arg"
            } else {
                Echo-Message -Err "Unknown package manager: $arg"
                Echo-Message -Info "Supported package managers: $($available_pms -join ', ')"
            }
        }
    }
}

function venv {  # deactivate if in a venv, or activate .venv/Scripts/activate
    if ($env:VIRTUAL_ENV) {
        Run-Verbose "deactivate"
    } elseif (Test-Path ".\.venv") {
        Run-Verbose ".\.venv\Scripts\activate"
    } else {
        Run-Verbose "uv venv"
        foreach ($file in @("requirements.txt", "requirements-dev.txt", "requirements-opt.txt")) {
            if (Test-Path ".\$file") {
                Run-Verbose "uv pip install -r .\$file"
            }
        }
        venv  # activate the venv
    }
}
proxy
