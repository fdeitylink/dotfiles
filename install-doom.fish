function install-doom
    echo "installing doom"
    if not test -e ~/.emacs.d
        git clone --depth 1 git@github.com:hlissner/doom-emacs.git ~/.emacs.d
        ~/.emacs.d/bin/doom -y install
        ~/.emacs.d/bin/doom sync
    else
        true
    end
end
