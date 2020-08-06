function install-doom
    echo "installing doom"
    if not test -e ~/.emacs.d
        git clone --depth 1 https://github.com/hlissner/doom-emacs ~/.emacs.d
        yes | ~/.emacs.d/bin/doom install
        ~/.emacs.d/bin/doom sync
    else
        true
    end
end
