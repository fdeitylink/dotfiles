set -gx EDITOR nvim
set -gx VISUAL emacs

set -gx GPG_TTY (tty)

set fish_user_paths ~/.local/bin ~/.config/emacs/bin

abbr vim nvim
abbr vi nvim
abbr ls exa
abbr tree 'exa -T'
abbr cat bat
abbr less 'bat --paging always'

fish_vi_key_bindings
fish_config theme choose 'Dracula Official'
fish_config prompt choose 'scales'
set -g fish_prompt_pwd_dir_length 0
set -g fish_greeting
