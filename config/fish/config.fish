fish_vi_key_bindings
if grep -qsi microsoft /proc/version
    set -Ux DISPLAY (string join ":" (awk '/nameserver / {print $2; exit}' /etc/resolv.conf  2>/dev/null) "0.0")
end
