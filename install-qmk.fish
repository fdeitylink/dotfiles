function install-qmk
    echo "installing qmk_firmware"
    if not test -e ~/qmk_firmware
        git clone --depth 1 --recurse-submodules git@github.com:qmk/qmk_firmware ~/qmk_firmware
    else
        true
    end
end
