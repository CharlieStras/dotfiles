export TERM=xterm-256color

#PROMPT STUFF
GREEN=$(tput setaf 2);
YELLOW=$(tput setaf 3);
WHITE=$(tput setaf 7)

function git_branch {
  # Shows the current branch if in a git repository
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\ \(\1\)/';
}

rand() {
  printf $((  $1 *  RANDOM  / 32767   ))
}
rand_element () {
  local -a th=("$@")
  unset th[0]
  printf $'%s\n' "${th[$(($(rand "${#th[*]}")+1))]}"
}

#Default Prompt
PS1="${YELLOW}\w${GREEN}\$(git_branch)${WHITE}\n$(rand_element 😅 👽 🔥 🚀 👻 ⛄ 👾 🍔 😄 🍰 🐑)  $ ";

# PATH ALTERATIONS
## Node
PATH="/usr/local/bin:$PATH";

# #Custom bins
PATH="$PATH:~/.bin";
# dotfile bins
PATH="$PATH:~/.my_bin";

## CDPATH ALTERATIONS
CDPATH=.:$HOME:$HOME/Developer:$HOME/Desktop

# Custom Aliases
alias ll="ls -al";
alias ..="cd ../";
alias ..l="cd ../ && ll";
alias pg="echo 'Pinging Google' && ping www.google.com";
alias oc="open -a 'Google Chrome' $1";
alias vb="vim ~/.bash_profile";
alias sb="source ~/.bash_profile";
alias mvrc="mvim ~/dotfiles/.vimrc";
alias de="cd ~/Desktop";
alias d="cd ~/Developer";
alias diary='pushd ~/Google\ Drive/Personal/Documents/Records/developer-diary && mvim `date +"%Y-%m-%d"`.md && popd'
cdl() { cd "$@" && ll; }
shorten() {
  hive-api --url "$1" --custom "$2";
}

alias lt="http-server ~/Developer/love-texts";

killport() { lsof -i tcp:"$@" | awk 'NR!=1 {print $2}' | xargs kill ;}

# git aliases
alias gc="git commit -m $1";
alias gs="git status";
alias gp="git pull";
alias gf="git fetch";
alias gpush="git push";

# Project aliases
alias af="cd ~/Developer/formly-js/angular-formly"

# javascript air
JSA_DIR="~/Developer/javascriptair/site"
alias jsa="cd $JSA_DIR"
alias sjsair="jsa && mvim && ttab -d $JSA_DIR npm run server && ttab -d $JSA_DIR npm run dev && open http://localhost:8080"
alias jsimg="node ~/Developer/javascriptair/images/ $1"

# npm aliases
alias ni="npm install";
alias nrs="npm run start";
alias nrb="npm run build";
alias nrt="npm run test";
alias rmn="rm -rf node_modules;"
alias flush-npm="rm -rf node_modules && npm i";

# PayPal aliases
alias p="cd ~/Developer/paypal/p2pnodeweb";

# Custom functions
mg () { mkdir "$@" && cd "$@" ; }

#nvm
source ~/.nvm/nvm.sh


# Because SourceTree's $PATH gets screwed up starting it normally...
alias st="open /Applications/SourceTree.app/Contents/MacOS/SourceTree";

# use hub for git
alias git=hub

# Bash completion
if [ -f $(brew --prefix)/etc/bash_completion ]; then
. $(brew --prefix)/etc/bash_completion
fi

export PATH="$PATH:$HOME/.rvm/bin"


[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

