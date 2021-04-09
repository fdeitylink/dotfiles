function install-doom
    echo "installing doom"
    if not test -e ~/.emacs.d
        git clone --depth 1 https://github.com/hlissner/doom-emacs ~/.emacs.d
        ~/.emacs.d/bin/doom install -y
        ~/.emacs.d/bin/doom sync
    else
        true
    end
end
