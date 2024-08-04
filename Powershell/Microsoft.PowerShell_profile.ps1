Invoke-Expression (&starship init powershell)
$env:PATH = (Get-Item $(python3 -m site --user-site)).parent.FullName + "\\Scripts" + ";$env:PATH"

function Echo-Message {
    param (
        [switch]$Err,
        [switch]$Warn,
        [switch]$Info,
        [switch]$Debug,
        [switch]$Title,
        [switch]$Command,
        [switch]$Ascii,
        [string]$Message
    )
    $Underline = "`e[4m"
    $Dim = "`e[2m"
    $Reset = "`e[0m"
    if ($Err) {
        Write-Output "${Dim}[${Reset}${Underline}❌Error${Reset}${Dim}]${Reset} ${Message}"
    } elseif ($Warn) {
        Write-Output "${Dim}[${Reset}⚠️Warning${Dim}]${Reset} ${Message}"
    } elseif ($Info) {
        Write-Output "${Dim}[ℹ️Info]${Reset} ${Message}"
    } elseif ($Debug) {
        Write-Output "[🐞Debug] ${Message}"
    } elseif ($Title) {
        Write-Output ""
        if ($Ascii) {
            $HorizontalBar = "=" * $Message.Length
            $VerticalBar = "|"
            $TopLeft = "+="
            $TopRight = "=+"
            $ButtomLeft = "+="
            $ButtomRight = "=+"
        } else {
            $HorizontalBar = "=" * $Message.Length
            $VerticalBar = "║"
            $TopLeft = "╔═"
            $TopRight = "═╗"
            $ButtomLeft = "╚═"
            $ButtomRight = "═╝"
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

function Run-Verbose([string]$Command) {
    Echo-Message -Command "$Command"
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
    function Upgrade-Pipx {  # Upgrade pipx's packages
        Echo-Message -Title 'Upgrade Pipx Packages'
        Run-Verbose "pipx upgrade-all"  # 20s
    }
    function Update-Pip {  # Update pip itself
        Echo-Message -Title 'Update pip'
        Run-Verbose "python3 -m pip install --upgrade pip"  # 3s
    }
    function Upgrade-Scoop {  # Upgrade scoop's packages
        Echo-Message -Title 'Upgrade Scoop Packages'
        Run-Verbose "scoop update *"  # 10+ s
        Run-Verbose "scoop cleanup *"  # 300+ ms
        Run-Verbose "scoop cache rm *"  # ~100 ms
    }

    $upgrades = @('pipx', 'scoop')  # Available package managers for upgrades
    $updates = @('pip')  # Available package managers to updates
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
                Echo-Message -Info "Supported package managers: $($upgrades -join ', ')"
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
        Run-Verbose "cmd /c mklink /D .venv\bin .venv\Scripts"  # create a symlink for 'bin' to 'Scripts' in .venv\
        venv  # activate the venv
    }
}
proxy
