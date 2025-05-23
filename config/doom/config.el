;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!

(use-package! doom-modeline
  :defer t
  :custom
  (doom-modeline-indent-info t))

(display-time)

(use-package! nyan-mode
  :after doom-modeline
  :custom
  (nyan-animate-nyancat t)
  (nyan-wavy-trail t)
  (nyan-minimum-window-width 128)
  :config
  (nyan-mode))

(use-package! beacon
  :config
  (beacon-mode))

(use-package! treemacs
  :defer t
  :custom
  (treemacs-missing-project-action 'remove)
  (+treemacs-git-mode 'extended)
  :config
  (treemacs-follow-mode t))

(use-package! lsp-ui
  :defer t
  :custom
  (lsp-ui-sideline-enable nil))

(use-package! lsp-treemacs
  :defer t
  :config
  (lsp-treemacs-sync-mode))

(use-package! straight
  :custom
  (straight-vc-git-default-protocol 'ssh))

(use-package! elcord
  :if (or (executable-find "discord")
          (executable-find "discord-ptb")
          (executable-find "discord-canary"))
  :config
  (elcord-mode))

(use-package! cider
  :defer t
  :custom
  (cider-clojure-cli-global-options "-J-XX:-OmitStackTraceInFastThrow")
  (nrepl-use-ssh-fallback-for-remote-hosts t))

(use-package! rust-mode
  :defer t
  :custom
  (lsp-rust-analyzer-cargo-watch-command "clippy"))

(use-package! haskell-mode
  :defer t
  :custom
  (haskell-interactive-popup-errors nil))

(when (locate-file "proverif" load-path load-suffixes)
  (setq auto-mode-alist (append '(("\\.horn$" . proverif-horn-mode)
                                  ("\\.horntype$" . proverif-horntype-mode)
                                  ("\\.pv[l]?$" . proverif-pv-mode)
                                  ("\\.pi$" . proverif-pi-mode))
                                auto-mode-alist))
  (autoload 'proverif-horn-mode "proverif" "Major mode for editing ProVerif code." t)
  (autoload 'proverif-horntype-mode "proverif" "Major mode for editing ProVerif code." t)
  (autoload 'proverif-pv-mode "proverif" "Major mode for editing ProVerif code." t)
  (autoload 'proverif-pi-mode "proverif" "Major mode for editing ProVerif code." t)

  (add-hook! (proverif-horn-mode proverif-horntype-mode proverif-pv-mode proverif-pi-mode)
    (unless (file-exists-p! (or "makefile" "Makefile"))
      (setq-local compile-command
                  (concat "proverif "
                          (if buffer-file-name (shell-quote-argument buffer-file-name)))))))

;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "Eloise Christian"
      user-mail-address "11952260+fdeitylink@users.noreply.github.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!
(setq doom-font (font-spec :family "JetBrains Mono" :size 12))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-dracula)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type 'relative)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
