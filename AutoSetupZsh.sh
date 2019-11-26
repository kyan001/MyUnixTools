#!/usr/bin/env zsh
if [ ! -d "$HOME/.oh-my-zsh/" ]; then  # dir not exist
    echo "oh-my-zsh is not exist. Installing ..."
    bash -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
else
    echo "oh-my-zsh already installed."
fi

powerlevel10k_name="powerlevel10k"
powerlevel10k_dir="${HOME}/.oh-my-zsh/custom/themes/${powerlevel10k_name}"
if [ ! -d "${powerlevel10k_dir}" ]; then
    echo "${powerlevel10k_name} is not exist. Installing ..."
    git clone https://github.com/romkatv/${powerlevel10k_name}.git ${powerlevel10k_dir}
else
    echo "${powerlevel10k_name} already installed."
fi

zsh_syntax_highlighting_name="zsh-syntax-highlighting"
zsh_syntax_highlighting_dir="${HOME}/.oh-my-zsh/custom/plugins/${zsh_syntax_highlighting_name}"
if [ ! -d "${zsh_syntax_highlighting_dir}" ]; then
    echo "${zsh_syntax_highlighting_name} is not exist. Installing ... ${zsh_syntax_highlighting_dir}"
    git clone https://github.com/zsh-users/${zsh_syntax_highlighting_name}.git ${zsh_syntax_highlighting_dir}
else
    echo "${zsh_syntax_highlighting_name} already installed."
fi

zsh_autosuggestions_name="zsh-autosuggestions"
zsh_autosuggestions_dir="${HOME}/.oh-my-zsh/custom/plugins/${zsh_autosuggestions_name}"
if [ ! -d "${zsh_autosuggestions_dir}" ]; then
    echo "${zsh_autosuggestions_name} is not exist. Installing ..."
    git clone https://github.com/zsh-users/${zsh_autosuggestions_name} ${zsh_autosuggestions_dir}
else
    echo "${zsh_autosuggestions_name} already installed."
fi

zsh_nvm_name="zsh-nvm"
zsh_nvm_dir="${HOME}/.oh-my-zsh/custom/plugins/${zsh_nvm_name}"
if [ ! -d "${zsh_nvm_dir}" ]; then
    echo "${zsh_nvm_name} is not exist. Installing ..."
    git clone https://github.com/lukechilds/${zsh_nvm_name} ${zsh_nvm_dir}
else
    echo "${zsh_nvm_name} already installed."
fi
