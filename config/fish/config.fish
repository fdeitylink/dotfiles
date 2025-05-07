set -gx EDITOR nvim
set -gx VISUAL emacs
set -gx PAGER 'bat --paging always'

set -gx GPG_TTY (tty)

set fish_user_paths ~/.local/bin ~/.config/emacs/bin

abbr vim nvim
abbr vi nvim
abbr ls eza
abbr tree 'eza -T'
abbr cat bat
abbr less $PAGER

fish_vi_key_bindings
fish_config theme choose 'Dracula Official'
fish_config prompt choose 'scales'
set -g fish_prompt_pwd_dir_length 0
set -g fish_greeting
