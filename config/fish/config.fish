set -gx EDITOR vim
set -gx VISUAL emacs

set -gx GPG_TTY (tty)

set fish_user_paths ~/.local/bin ~/.emacs.d/bin

alias vim nvim
alias vi nvim
alias ls exa
alias tree 'exa -T'
alias cat bat

fish_vi_key_bindings
fish_config theme choose 'Dracula Official'
fish_config prompt choose 'scales'
set -g fish_prompt_pwd_dir_length 0
set -g fish_greeting
