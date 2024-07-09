Invoke-Expression (&starship init powershell)
$env:PATH = (Get-Item $(python3 -m site --user-site)).parent.FullName + "\\Scripts" + ";$env:PATH"

function Run-Command([string]$Command) {
    $underline = "`e[4m"
    $dim = "`e[2m"
    $reset = "`e[0m"
    Write-Host "`n$dim>_$reset $underline$Command$reset"
    Invoke-Expression $Command
}
function proxy {  # toggle using proxy
    $proxy_addr = "http://127.0.0.1:1088"
    if (!$env:ALL_PROXY -and !$env:HTTPS_PROXY -and !$env:HTTP_PROXY) {
        $env:ALL_PROXY = $proxy_addr
        $env:HTTPS_PROXY = $proxy_addr
        $env:HTTP_PROXY = $proxy_addr
        Write-Host "[Proxy ON] ALL_PROXY, HTTPS_PROXY and HTTP_PROXY set to $proxy_addr. Use 'Proxy' to turn off."
    } else {
        if ($env:ALL_PROXY) {
            Remove-Item Env:\ALL_PROXY
            Write-Host "[Proxy OFF] ALL_PROXY unset from $env:ALL_PROXY."
        }
        if ($env:HTTP_PROXY) {
            Remove-Item Env:\HTTP_PROXY
            Write-Host "[Proxy OFF] HTTP_PROXY unset."
        }
        if ($env:HTTPS_PROXY) {
            Remove-Item Env:\HTTPS_PROXY
            Write-Host "[Proxy OFF] HTTPS_PROXY unset."
        }
    }
}
function fzfcd {
    Set-Location (fzf --preview 'bat --color=always --line-range=:100 {}' --preview-window up | Split-Path -Parent)
}
function up {  # upgrade pip/pipx/scoop, and pipx/scoop packages.
    Run-Command "python3 -m pip install --upgrade pip"
    Run-Command "pipx upgrade-all"
    Run-Command "scoop update *"
    Run-Command "scoop cleanup *"
    Run-Command "scoop cache rm *"
}
function venv {  # deactivate if in a venv, or activate .venv/Scripts/activate
    if ($env:VIRTUAL_ENV) {
        Run-Command "deactivate"
    } elseif (Test-Path ".\.venv") {
        Run-Command ".\.venv\Scripts\activate"
    } else {
        Run-Command "uv venv"
        foreach ($file in @("requirements.txt", "requirements-dev.txt", "requirements-opt.txt")) {
            if (Test-Path ".\$file") {
                Run-Command "uv pip install -r .\$file"
            }
        }
        venv  # activate the venv
    }
}
proxy
