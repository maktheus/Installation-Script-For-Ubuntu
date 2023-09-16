#!/bin/bash

# Função para verificar e lidar com erros
check_error() {
  if [ $? -ne 0 ]; then
    if command -v gum &>/dev/null; then
      gum style \
      --foreground 196 --border-foreground 196 --border double \
      --align center --width 50 --margin "1 2" --padding "2 4" \
      "🚫 Erro: $1"
    else
      echo "🚫 Erro: $1"
    fi
    exit 1
  fi
}

# Função para verificar e informar que um pacote foi instalado
check_installed() {
  if [ $? -eq 0 ]; then
    if command -v gum &>/dev/null; then
      gum style \
      --foreground 78 --border-foreground 78 --border double \
      --align center --width 50 --margin "1 2" --padding "2 4" \
      "✅ $1 instalado com sucesso."
    else
      echo "✅ $1 instalado com sucesso."
    fi
  fi
}

# Verificar se o script está sendo executado como root
if [ "$EUID" -eq 0 ]; then
  if command -v gum &>/dev/null; then
    gum style \
    --foreground 196 --border-foreground 196 --border double \
    --align center --width 50 --margin "1 2" --padding "2 4" \
    "🚫 Erro: não execute este script como root."
  else
    echo "🚫 Erro: não execute este script como root."
  fi
  exit 1
fi

# print comum para o script
if command -v gum &>/dev/null; then
  gum style \
  --foreground 78 --border-foreground 78 --border double \
  --align center --width 50 --margin "1 2" --padding "2 4" \
  "Iniciando a instalação..."
else
  echo "Iniciando a instalação..."
fi

# Atualizar a lista de pacotes (apenas para sistemas baseados em apt)
if command -v apt-get &>/dev/null; then
  echo "Atualizando lista de pacotes..."
  sudo apt-get update
  
  check_error "Falha ao atualizar a lista de pacotes."
  check_installed "Lista de pacotes"
fi

# Verificar e instalar Git
if ! command -v git &>/dev/null; then
  echo "Instalando Git..."
  sudo apt-get install -y git
  check_error "Falha ao instalar o Git."
  check_installed "Git"
fi

# Verificar e instalar Curl
if ! command -v curl &>/dev/null; then
  echo "Instalando Curl..."
  sudo apt-get install -y curl
  
  check_error "Falha ao instalar o Curl."
  check_installed "Curl"
fi

# Verificar e instalar build-essential
if ! command -v build-essential &>/dev/null; then
  echo "Instalando build-essential..."
  sudo apt-get install -y build-essential
  
  check_error "Falha ao instalar o build-essential."
  check_installed "build-essential"
fi

# Verificar e instalar Homebrew (caso esteja usando macOS)
if ! command -v brew &>/dev/null; then
  echo "Instalando Homebrew..."
  (echo; echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"') >> /home/temp/.zprofile
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  check_error "Falha ao instalar o Homebrew."
  check_installed "Homebrew"
fi

# Adicionar homebrew ao PATH
if ! command -v brew &>/dev/null; then
  echo "Adicionando Homebrew ao PATH..."
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
  eval "$(/opt/homebrew/bin/brew shellenv)"
  
  check_error "Falha ao adicionar o Homebrew ao PATH."
fi


# Verificar e instalar gum
if ! command -v gum &>/dev/null; then
  echo "Instalando Gum..."
  brew install gum
  check_error "Falha ao instalar o Gum."
  check_installed "Gum"
fi

# Mensagem de início

if command -v gum &>/dev/null; then
  gum style \
  --foreground 78 --border-foreground 78 --border double \
  --align center --width 50 --margin "1 2" --padding "2 4" \
  "Iniciando a instalação..."
else
  echo "Iniciando a instalação..."
fi


# Verificar e instalar Exa
if ! command -v exa &>/dev/null; then
  echo "Instalando Exa..."
  brew install exa
  check_error "Falha ao instalar o Exa."
  check_installed "Exa"
fi

# Change my ls to exa with icons and colors and stuff 
if ! command -v ls &>/dev/null; then
  alias ls='exa --icons --color=always'
  echo "alias ls='exa --icons --color=always'" >> "$HOME/.zshrc"

fi

# Verificar e instalar rclone
if ! command -v rclone &>/dev/null; then
  echo "Instalando rclone..."
  sudo apt-get install -y rclone
  check_error "Falha ao instalar o rclone."
  check_installed "rclone"
fi

# Verificar e instalar Zsh
if ! command -v zsh &>/dev/null; then
  echo "Instalando Zsh..."
  sudo apt install -y zsh
  check_error "Falha ao instalar o Zsh."
  check_installed "Zsh"
fi

# Definir Zsh como o shell padrão
if [ ! "$SHELL" = "/bin/zsh" ]; then
  echo "Definindo Zsh como o shell padrão..."
  chsh -s /bin/zsh
  check_error "Falha ao definir o Zsh como o shell padrão."
  
fi

# Verificar e instalar Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Instalando Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  check_error "Falha ao instalar o Oh My Zsh."

fi

# Verificar e instalar Zinit (gerenciador de plugins Zsh)
if [ ! -d "$HOME/.zinit" ]; then
  echo "Instalando Zinit..."
  bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
  check_error "Falha ao instalar o Zinit."
  check_installed "Zinit"
fi

# Clonar o repositório Git que contém o .zshrc personalizado
if [ ! -d "$HOME/Dotfiles" ]; then
  echo "Clonando repositório Dotfiles..."
  git clone https://github.com/maktheus/Dotfiles.git "$HOME/Dotfiles"
  check_error "Falha ao clonar o repositório Dotfiles."
fi

# Substituir o .zshrc gerado pelo script pelo .zshrc personalizado
if [ -f "$HOME/Dotfiles/.zshrc" ]; then
  echo "Substituindo o .zshrc gerado pelo script pelo .zshrc personalizado..."
  mv "$HOME/Dotfiles/.zshrc" "$HOME/.zshrc"
  check_error "Falha ao substituir o .zshrc."
fi

# Verificar e instalar o Visual Studio Code (VS Code) via Snap
if ! command -v code &>/dev/null; then
  echo "Instalando o Visual Studio Code..."
  sudo snap install code --classic
  check_error "Falha ao instalar o Visual Studio Code."
  check_installed "Visual Studio Code"
fi

# Verificar e instalar Fuzzy finder
if ! command -v fzf &>/dev/null; then
  echo "Instalando o Fuzzy finder..."
  sudo apt-get install -y fzf
  check_error "Falha ao instalar o Fuzzy finder."
  check_installed "Fuzzy finder"
fi

#add this Alias cd $(find * -type d | fzf)
if ! command -v fzf &>/dev/null; then
        alias cdf='cd $(find * -type d | fzf)'

      # Check if .zshrc exists
      if [ -f ~/.zshrc ]; then
          # Check if the alias already exists in .zshrc
          if ! grep -q "alias cdfzf='cd \$(find * -type d | fzf)'" ~/.zshrc; then
              # Add the alias to .zshrc
              echo "alias cdfzf='cd \$(find * -type d | fzf)'" >> ~/.zshrc
          else
              echo "Alias 'cdfzf' already exists in your .zshrc file. No changes made."
          fi
      else
          echo "The .zshrc file does not exist in your home directory."
          echo "You can create one manually and add the alias to it."
      fi

fi



# Verificar e instalar cmatrix
if ! command -v cmatrix &>/dev/null; then
  echo "Instalando o cmatrix..."
  sudo apt-get install -y cmatrix
  check_error "Falha ao instalar o cmatrix."
  check_installed "cmatrix"
fi

# Verificar e instalar Neofetch
if ! command -v neofetch &>/dev/null; then
  echo "Instalando o Neofetch..."
  sudo apt-get install -y neofetch
  check_error "Falha ao instalar o Neofetch."
  check_installed "Neofetch"

fi

#souce the .zshrc
source "$HOME/.zshrc"

# Mensagem de conclusão

if ! command -v gum &>/dev/null; then
  gum style \
	--foreground 212 --border-foreground 212 --border double \
	--align center --width 50 --margin "1 2" --padding "2 4" \
    'Instalação concluída!'
fi

# create ssh-key
ssh-keygen 

#print the ssh-key
cat ~/.ssh/id_rsa.pub

# install xclip
sudo apt-get install xclip
check_error "Falha ao instalar o xclip."
check_installed "xclip"

# alias to xclip as copy 
alias copy="xclip -sel clip"
# add to .zshrc
echo "alias copy="xclip -sel clip"" >> "$HOME/.zshrc"

# copy to clipboard
xclip -sel clip < ~/.ssh/id_rsa.pub



# Instalação concluída
echo "Instalação concluída."
