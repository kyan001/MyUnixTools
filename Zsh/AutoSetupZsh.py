#!/usr/bin/env python3
import os

import consoleiotools as cit
import consolecmdtools as cct

COMPONENTS = {
    "zsh": {
        "path": "/bin/zsh",
        "cmds": [
            "sudo apt-get install zsh",
        ],
    },
    "oh-my-zsh": {
        "path": "{HOME}/.oh-my-zsh/",
        "cmds": [
            'bash -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"',
        ],
    },
    "powerlevel10k": {
        "path": "{HOME}/.oh-my-zsh/custom/themes/powerlevel10k",
        "cmds": [
            "git clone --depth=1 https://github.com/romkatv/powerlevel10k.git {path}",
        ],
    },
    "zsh-syntax-highlighting": {
        "path": "{HOME}/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting",
        "cmds": [
            "git clone https://github.com/zsh-users/zsh-syntax-highlighting.git {path}",
        ],
    },
    "zsh-autosuggestions": {
        "path": "{HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions",
        "cmds": [
            "git clone https://github.com/zsh-users/zsh-autosuggestions {path}",
        ],
    },
    "zsh-nvm": {
        "path": "{HOME}/.oh-my-zsh/custom/plugins/zsh-nvm",
        "cmds": [
            "git clone https://github.com/lukechilds/zsh-nvm {path}",
        ]
    },
}


@cit.as_session
def install_if_needed(path: str, cmds: list, name: str):
    """Install if target path is not exist."""
    cit.info("《{}》".format(name.upper()))
    path = path.format(HOME=os.environ.get('HOME'))
    if not os.path.exists(path):
        cit.warn("Component is not exist. Installing ...")
        cit.info("Path = {}".format(path))
        for cmd in cmds:
            cmd = cmd.format(path=path)
            cct.run_cmd(cmd)
    else:
        cit.info("Component is already installed.")


def main():
    for name, values in COMPONENTS.items():
        install_if_needed(values["path"], values["cmds"], name)
    zshrc_path = os.path.expanduser("~/.zshrc")
    cct.copy_file(os.path.join(cct.get_path(__file__).parent, "zshrc"), zshrc_path)


if __name__ == '__main__':
    main()
