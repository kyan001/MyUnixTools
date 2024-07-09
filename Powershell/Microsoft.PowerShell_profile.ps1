Invoke-Expression (&starship init powershell)
$env:PATH = (get-item $(python3 -m site --user-site)).parent.FullName + "\\Scripts" + ";$env:PATH"
function Proxy {  # toggle using proxy
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
    Write-Host "`n→ python3 -m pip install --upgrade pip"
    python3 -m pip install --upgrade pip
    Write-Host "`n→ pipx upgrade-all"
    pipx upgrade-all
    Write-Host "`n→ scoop update *"
    scoop update *
    Write-Host "`n→ scoop cleanup *"
    scoop cleanup *
    Write-Host "`n→ scoop cache rm *"
    scoop cache rm *
}
function venv {  # deactivate if in a venv, or activate .venv/Scripts/activate
    if ($env:VIRTUAL_ENV) {
        Write-Host "→ deactivate"
        deactivate
    } elseif (Test-Path ".\.venv") {
        Write-Host "→ .\.venv\Scripts\activate"
        .\.venv\Scripts\activate
    } else {
        Write-Host "→ uv venv"
        uv venv
        if (Test-Path ".\requirements.txt") {
            Write-Host "→ uv pip install -r .\requirements.txt"
            uv pip install -r .\requirements.txt
        }
        if (Test-Path ".\requirements-dev.txt") {
            Write-Host "→ uv pip install -r .\requirements-dev.txt"
            uv pip install -r .\requirements-dev.txt
        }
        if (Test-Path ".\requirements-opt.txt") {
            Write-Host "→ uv pip install -r .\requirements-opt.txt"
            uv pip install -r .\requirements-opt.txt
        }
    }
}
Proxy
