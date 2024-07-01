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
function upgrades {
    python3 -m pip install --upgrade pip
    pipx upgrade-all
    scoop update *
    scoop cleanup *
    scoop cache rm *
}
Proxy
