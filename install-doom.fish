function install-doom
    echo "installing doom"
    if not test -e ~/.config/emacs
        git clone --depth 1 git@github.com:doomemacs/doomemacs.git ~/.config/emacs
        doom -! install
    else
        true
    end
end
