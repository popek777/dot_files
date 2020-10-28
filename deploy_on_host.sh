#!/bin/bash

# smple script to deploy dot files on host

REPO_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"

# update submodules
cd $REPO_DIR
git submodule update --init --recursive

# install YCM vim plugin
sudo apt-get install build-essential cmake
sudo apt-get install python-dev python3-dev
cd $REPO_DIR/.vim/bundle/YouCompleteMe && ./install.py --clang-completer

echo 'install compiledb (to be able to generated compile_commands.json used by YCM vim plugin'
sudo apt-get install python-pip
pip install compiledb

echo 'install node js'
curl -sL install-node.now.sh/lts | bash

# https://classic.yarnpkg.com/en/docs/install#debian-stable
ech 'install yarn'
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee/etc/apt/sources.list.d/yarn.list
sudo apt update && sudo apt install yarn

function link_config()
{
  link=$HOME/$1
  target=$REPO_DIR/$1

  if [ -L "$link" ]; then
    echo current $link is soft link. Removing it.
    unlink $link
  elif [ -e "$link" ]; then
    echo backing up current $link into: $HOME/.backups
    mkdir -p $HOME/.backups
    mv $link $HOME/.backups
  fi

  ln -s $target $link
}

link_config .vim
link_config .vimrc
link_config .tmux.conf

echo 'source $REPO_DIR/.bashrc_extras' >> $HOME/.bashrc

