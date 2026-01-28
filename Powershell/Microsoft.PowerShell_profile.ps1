function Loading-Time ($StartTime = $null) {
    if (-not $StartTime) {
        Write-Host "🛫 PowerShell Profile: Loading" -ForegroundColor Yellow
        return Get-Date
    } else {
        $Duration = (Get-Date) - $StartTime
        Write-Host "🛬 PowerShell Profile: Loaded ($([int]($Duration.TotalSeconds * 1000))ms)" -ForegroundColor Green
    }
}
$StartTime = Loading-Time


<# Utility Functions for Powershell #>
class Ansi {
    <#
    .SYNOPSIS
        Class for ANSI text styles

    .EXAMPLE
        PS> [Ansi]::Bold("text")
        PS> ([Ansi]::Italic("text"))
        PS> "$([Ansi]::Underline("text"))"
        PS> "${[Ansi]::Dim("text")}"
        PS> "..." | { [Ansi]::Underline($_) } | Write-Host  # Pipe input
        PS> "$([Ansi]::Char.Bold)...$([Ansi]::Char.Reset)"  # Using ANSI Chars
    #>
    static [hashtable] $Char = @{
        Reset      = "`e[0m"
        Bold       = "`e[1m"
        Dim        = "`e[2m"
        Italic     = "`e[3m"
        Underline  = "`e[4m"
        EraseRight = "`e[0K"
        EraseLeft  = "`e[1K"
        EraseLine  = "`e[2K"
        CursorUp   = "`e[1A"
        CursorDown = "`e[1B"
    }

    static [string] Bold ([string]$Text) {
        return "`e[1m$Text`e[0m"
    }

    static [string] Dim ([string]$Text) {
        return "`e[2m$Text`e[0m"
    }

    static [string] Italic ([string]$Text) {
        return "`e[3m$Text`e[0m"
    }

    static [string] Underline ([string]$Text) {
        return "`e[4m$Text`e[0m"
    }

    static [string] Strip ([string]$Text) {
        <#
        .SYNOPSIS
            Strip ANSI codes from text
        .EXAMPLE
            PS> [Ansi]::Strip("`e[1mtext`e[0m")
        #>
        return $Text -replace "`e\[[0-9:;<=>?]*[ -/]*[@-~]", ""
    }
}

<#
    .SYNOPSIS
        Shortcuts for ANSI styles
    .EXAMPLE
        PS> _B("text")
        PS> _D("text")
        PS> _I("text")
        PS> _U("text")
        PS> _U(_I(_B(_D("text"))))  # Nested
        PS> (_B "text")  # Without parentheses
        PS> "$(_B("text"))"  # In string interpolation
#>
function _B ($Text) { return [Ansi]::Bold($Text) }  # Bold Shortcut
function _D ($Text) { return [Ansi]::Dim($Text) }  # Dim Shortcut
function _I ($Text) { return [Ansi]::Italic($Text) }  # Italic Shortcut
function _U ($Text) { return [Ansi]::Underline($Text) }  # Underline Shortcut

function Echo-Message {
    <#
    .SYNOPSIS
        Print message with different styles

    .EXAMPLE
        Echo-Message -Err "This is an error message"
        Echo-Message -Warn "This is a warning message"
        Echo-Message -Info "This is an info message"
        Echo-Message -Debug "This is a debug message"
        Echo-Message -Title "This is a title message"
        Echo-Message -Command "This is a command message"
        Echo-Message "This is a normal message"
    #>
    param (
        [switch]$Err,
        [switch]$Warn,
        [switch]$Info,
        [switch]$Debug,
        [switch]$Title,
        [switch]$Command,
        [string]$Message
    )
    if ($Err) {
        Write-Host "$(_D("["))$(_U("Error"))$(_D("]")) $Message"
    } elseif ($Warn) {
        Write-Host "$(_D("["))$(_U("Warning"))$(_D("]")) $Message"
    } elseif ($Info) {
        Write-Host "$(_D("[Info]")) $Message"
    } elseif ($Debug) {
        Write-Host "[Debug] ${Message}" -ForegroundColor Gray
    } elseif ($Title) {
        Write-Host ""
        if ($Host.UI.SupportsVirtualTerminal) {  # Check if the host supports virtual terminal (ANSI and Unicode)
            $HorizontalBar = (New-Object string ([char]0x2550), $Message.Length)  # "═" * $Message.Length
            $VerticalBar = [char]0x2551  # "║"
            $TopLeft = [char]0x2554 + [char]0x2550  # "╔═"
            $TopRight = [char]0x2550 + [char]0x2557  # "═╗"
            $BottomLeft = [char]0x255A + [char]0x2550  # "╚═"
            $BottomRight = [char]0x2550 + [char]0x255D  # "═╝"
        } else {
            $HorizontalBar = "=" * $Message.Length
            $VerticalBar = "|"
            $TopLeft = "+="
            $TopRight = "=+"
            $BottomLeft = "+="
            $BottomRight = "=+"
        }
        Write-Host (_D("${TopLeft}${HorizontalBar}${TopRight}"))
        Write-Host (_D("${VerticalBar}") + " ${Message} " + _D("${VerticalBar}"))
        Write-Host (_D("${BottomLeft}${HorizontalBar}${BottomRight}"))
    } elseif ($Command) {
        Write-Host (_D(">_") + " " + _U("${Message}"))
    } else {
        Write-Host "${Message}"
    }
}


function Run-Command ([switch]$Verbose, [string]$Command) {
    <#
    .SYNOPSIS
        Run a command, optionally printing it before running.

    .EXAMPLE
        Run-Command "Get-Process"  # Just run the command
        Run-Command -Verbose "Get-Process"  # Print the command before running it.
    #>
    if ($Verbose) {
        Echo-Message -Command "$Command"
    }
    Invoke-Expression $Command
}


function Has-Command ([switch]$Verbose, [string]$Command) {
    <#
    .SYNOPSIS
        Check if a command exists

    .EXAMPLE
        if (Has-Command "cmd") { ... }
        if (Has-Command -Verbose "cmd" ) {... }

    .OUTPUTS
        [bool] True if the command exists, False otherwise.
    #>
    if (Get-Command $Command -ErrorAction SilentlyContinue) {
        return $true
    } else {
        if ($Verbose) {
            Echo-Message -Err "Command not found: $Command"
        }
        return $false
    }
}


function Press-To-Continue ([switch]$Enter) {
    <#
    .SYNOPSIS
        Prompt the user to press any key or Enter to continue.

    .EXAMPLE
        PS> Press-To-Continue
        PS> Press-To-Continue -Enter  # Wait for Enter key instead of any key.
    #>
    if ($Enter) {
        Read-Host "Press Enter To Continue ..."
    } else {
        Write-Host "Press Any Key To Continue ..."
        $null = $Host.UI.RawUI.ReadKey()
    }
}


<# Script Initialization #>
if (Has-Command starship) {  # Activate Starship prompt
    Invoke-Expression (&starship init powershell)
}

if (Has-Command zoxide) {  # Init Zoxide (z and zi)
    #$env:_ZO_FZF_OPTS = "--preview 'bat --color=always --line-range=:100 {}' --preview-window up"  # Set fzf options for Zoxide
    Invoke-Expression (& { (zoxide init powershell | Out-String) })  # Init Zoxide
}

if (Has-Command python3) {  # Add Python3 Scripts to PATH
    $env:PATH = (Get-Item $(python3 -m site --user-site)).parent.FullName + "\\Scripts" + ";$env:PATH"
}


function proxy ([string]$Action, [switch]$Quiet) {
    <#
    .SYNOPSIS
        Manage proxy environment variables for the current PowerShell session.

    .EXAMPLE
        proxy  # Toggle proxy on/off
        proxy on  # Enable proxy
        proxy off  # Disable proxy
        proxy status  # Show current proxy settings
        proxy -Quiet on  # Enable proxy without output
        proxy -Quiet off  # Disable proxy without output
    #>
    $proxy_address = "127.0.0.1:1088"
    $proxy_protocol = "http"  # http | socks5
    $proxy_envvars = @("http_proxy", "https_proxy", "all_proxy", "HTTP_PROXY", "HTTPS_PROXY", "ALL_PROXY")

    switch ("$Action".ToLowerInvariant()) {
        "" {  # Toggle proxy
            foreach ($envvar in $proxy_envvars) {
                if ([Environment]::GetEnvironmentVariable($envvar)) {  # If any proxy envvar is set, turn off all proxy envvars
                    Run-Command -Verbose:(-not $Quiet) "proxy off"
                    return
                }
            }
            Run-Command -Verbose:(-not $Quiet) "proxy on"  # If no proxy envvar is set, turn on all proxy envvars
        }
        "on" {
            foreach ($envvar in $proxy_envvars) {
                if (-not [Environment]::GetEnvironmentVariable($envvar)) {
                    [Environment]::SetEnvironmentVariable($envvar, "${proxy_protocol}://${proxy_address}", "Process")
                    if (-not $Quiet) {
                        Echo-Message -Command "`$env:$envvar = ${proxy_protocol}://${proxy_address}"
                    }
                }
            }
        }
        "off" {
            foreach ($envvar in $proxy_envvars) {
                if ([Environment]::GetEnvironmentVariable($envvar)) {
                    Remove-Item "Env:\$envvar"
                    if (-not $Quiet) {
                        Echo-Message -Command "Remove-Item Env:\$envvar"
                    }
                }
            }
        }
        "status" {
            foreach ($envvar in $proxy_envvars) {
                if ([Environment]::GetEnvironmentVariable($envvar)) {
                    Echo-Message -Info "`$env:$envvar = $([Environment]::GetEnvironmentVariable($envvar))"
                } else {
                    Echo-Message -Info "`$env:$envvar = <unset>"
                }
            }
        }
        default {
            Echo-Message -Err "Unknown action: $Action"
            Echo-Message -Info "Usage [on|off|status] [-Quiet]"
        }
    }
}


function fzfcd {
    <#
    .SYNOPSIS
        # Use fzf to select a file, and cd to its directory
    .EXAMPLE
        PS> fzfcd
    #>
    if (Has-Command -Verbose fzf) {
        if (Has-Command bat) {
            $Selection = fzf --preview 'bat --color=always --line-range=:100 {}' --preview-window up
        } else {
            $Selection = fzf
        }
        if ($Selection) {
            if (Test-Path $Selection -PathType Container) {
                Set-Location $Selection
            } else {
                Set-Location (Split-Path -Parent $Selection)
            }
        }
    }
}


function up {
    <#
    .SYNOPSIS
        Update package managers information and upgrade packages

    .EXAMPLE
        up  # Run daily Updates & Upgrades
        up -All  # Upgrade all supported package managers and update packages
        up -List  # List all supported package managers and packages
        up -Help  # Show help message
        up pipx scoop  # Update & Upgrade only pipx and scoop packages
        up clash  # Upgrade only clash
    .NOTES
        The term `update` means to get the latest package information from remote servers.
        The term `upgrade` means to actually install the latest versions of the packages.
    #>
    param (
        [switch]$All,  # `up -All` to run all upgrades and updates
        [switch]$Help,  # `up -Help` to show help message
        [switch]$List,  # `up -List` to list all supported packages and package managers
        [string[]]$Targets = @()  # `up pipx scoop` to run pipx and scoop upgrades only
    )

    function Up-Pipx {
        Echo-Message -Title 'Pipx Update & Upgrades'
        if (Has-Command -Verbose pipx) {  # Return if pipx not found
            Run-Command -Verbose "pipx upgrade-all"  # 20s
        }
    }

    function Up-Scoop {
        Echo-Message -Title 'Scoop Update & Upgrades'
        if (Has-Command -Verbose scoop) {  # Return if scoop not found
            Run-Command -Verbose "scoop update *"  # 10+ s
            Run-Command -Verbose "scoop cleanup *"  # 300+ ms
            Run-Command -Verbose "scoop cache rm *"  # ~100 ms
        }
    }

    function Up-Winget {
        Echo-Message -Title 'Winget Update & Upgrades'
        if (Has-Command -Verbose winget) {  # Return if winget not found
            Echo-Message -Command "winget upgrade --all --accept-package-agreements --accept-source-agreements"
            Start-Process winget -ArgumentList @('upgrade', '--all', '--accept-package-agreements', '--accept-source-agreements') -NoNewWindow -Wait  # Avoid output clutter
        }
    }

    function Up-Rust {
        Echo-Message -Title 'Upgrade Rust Toolchain'
        if (Has-Command -Verbose rustup) {  # Return if rust not found
            Run-Command -Verbose "rustup update"
        }
    }

    function Up-Pip {
        Echo-Message -Title 'Upgrade pip itself'
        if (Has-Command -Verbose python3) {  # Return if pip not found
            Run-Command -Verbose "python3 -m pip install --upgrade pip"  # 3s
        }
    }

    function Up-DotNet {
        Echo-Message -Title 'Upgrade Windows Desktop Runtime (.NET)'
        if (Has-Command -Verbose scoop) {
            Run-Command -Verbose "sudo scoop update windowsdesktop-runtime"
        }
    }

    function Up-Clash {
        Echo-Message -Title 'Upgrade Clash Verge Rev'
        if (Has-Command -Verbose scoop) {
            Run-Command -Verbose "scoop download clash-verge-rev"
            Run-Command -Verbose "sudo scoop update clash-verge-rev"
        }
    }

    function Up-Zed {
        Echo-Message -Title 'Upgrade Zed'
        if ((Has-Command -Verbose winget) -and (Has-Command -Verbose zed)) {
            $ZedPath = Split-Path (Split-Path (Get-Command zed).Source)
            Echo-Message -Command "winget install ZedIndustries.Zed --force --source winget --location `"$ZedPath`""
            Start-Process winget -ArgumentList @('install', 'ZedIndustries.Zed', '--force', '--source', 'winget', "--location", "$ZedPath") -NoNewWindow -Wait
        }
    }
    $PackageManagers = @{
        'pipx' = { Up-Pipx }
        'scoop' = { Up-Scoop }
        'winget' = { Up-Winget }
    }
    $DailyUpgrades = @{
        'pip' = { Up-Pip }
        'rust' = { Up-Rust }
    }
    $Packages = $DailyUpgrades + @{
        'dotnet' = { Up-DotNet }
        'clash' = { Up-Clash }
        'zed' = { Up-Zed }
    }
    $PrintList = {
        Echo-Message -Info "Supported Packages and Managers:`n`t$(@($PackageManagers.Keys + $Packages.Keys) -join ', ')"
    }
    if ($All) {  # Run 'up -All' to run all upgrades and updates
        foreach ($Func in $PackageManagers.Values) {
            $Func.Invoke()
        }
        foreach ($Func in $Packages.Values) {
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
    if ($Targets.Count -eq 0) {  # Run daily Updates & Upgrades
        foreach ($Func in $PackageManagers.Values) {  # All package managers will be Updates & Upgrades
            $Func.Invoke()
        }
        foreach ($Func in $DailyUpgrades.Values) {  # Partial packages will be upgraded daily
            $Func.Invoke()
        }
    } else {
        foreach ($target in $Targets) {
            if ($PackageManagers.ContainsKey($target)) {  # $target is in $PackageManagers
                $PackageManagers[$target].Invoke()
            } elseif ($Packages.ContainsKey($target)) {  # $target is in $Packages
                $Packages[$target].Invoke()
            } else {
                Echo-Message -Err "Unknown package manager: $target"
                $PrintList.Invoke()
            }
        }
    }
}

function venv {
    <#
    .SYNOPSIS
        Deactivate if in a venv, or activate .venv\Scripts\activate

    .EXAMPLE
        venv  # Activate or deactivate venv
    #>
    $requirements = @("requirements.txt", "requirements-dev.txt", "requirements-opt.txt")
    # If venv is activated, deactivate it.
    if ($env:VIRTUAL_ENV) {
        Run-Command -Verbose "deactivate"
        return
    }
    # If uv is not installed, return
    if (-not (Has-Command -Verbose uv)) {
        return $false
    }
    # If .venv\ not exists, create venv and relaunch the function.
    if (-not (Test-Path ".\.venv")) {
        Run-Command -Verbose "uv venv"
        venv
        return
    }
    # If .venv\ exists, but not executable, recreate venv and relaunch the function.
    if (-not (Test-Path ".\.venv\Scripts\python.exe")) {
        Run-Command -Verbose "Remove-Item -Recurse .\.venv"
        venv
        return
    }
    # If .venv\ exists, but version is old, recreate the.venv\
    try {
        & .\.venv\Scripts\python.exe --version > $null 2>&1
    } catch {
        Run-Command -Verbose "Remove-Item -Recurse .\.venv"
        venv
        return
    }
    # If .venv\ exists, and python is executable, update it and activate
    foreach ($file in $requirements) {
        if (Test-Path ".\$file") {
            Run-Command -Verbose "uv pip install --refresh -r .\$file"
        }
    }
    # If .venv\bin\ not exists, create a symlink for it to .venv\Scripts\
    if (-not (Test-Path "${PWD}\.venv\bin")) {
        Run-Command -Verbose "cmd /c mklink /D `"${PWD}\.venv\bin`" `"${PWD}\.venv\Scripts`""  # Create a symlink for 'bin' to 'Scripts' in .venv\
    }
    # Activate the venv
    Run-Command -Verbose ".\.venv\Scripts\activate"
}

# Main
proxy -Quiet on

# Final
Loading-Time $StartTime
