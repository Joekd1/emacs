;; Keep our init.el clean
(setq custom-file (locate-user-emacs-file "custom.el"))
(load custom-file :no-error-if-file-is-missing)

;; Make Emacs more minimal
(setq inhibit-startup-message t)
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

;; line numbers
(global-display-line-numbers-mode t)
(setq display-line-numbers-type 'relative)

;; Disable line numbers for some modes
(setq no-line-numbers-modes '(org-mode-hook
			      term-mode-hook
			      shell-mode-hook
			      eshell-mode-hook
			      lisp-interaction-mode-hook))

(dolist (mode no-line-numbers-modes)
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

(add-to-list 'default-frame-alist '(font . "JetBrainsMono Nerd Font 13"))

(use-package ef-themes
  :ensure t
  :init
  ;; This makes the Modus commands listed below consider only the Ef
  ;; themes.  For an alternative that includes Modus and all
  ;; derivative themes (like Ef), enable the
  ;; `modus-themes-include-derivatives-mode' instead.  The manual of
  ;; the Ef themes has a section that explains all the possibilities:
  ;;
  ;; - Evaluate `(info "(ef-themes) Working with other Modus themes or taking over Modus")'
  ;; - Visit <https://protesilaos.com/emacs/ef-themes#h:6585235a-5219-4f78-9dd5-6a64d87d1b6e>
  (ef-themes-take-over-modus-themes-mode 1)
  :bind
  (("<f5>" . modus-themes-rotate)
   ("C-<f5>" . modus-themes-select)
   ("M-<f5>" . modus-themes-load-random))
  :config
  ;; All customisations here.
  (setq modus-themes-mixed-fonts t)
  (setq modus-themes-italic-constructs t)

  ;; Finally, load your theme of choice (or a random one with
  ;; `modus-themes-load-random', `modus-themes-load-random-dark',
  ;; `modus-themes-load-random-light').
  (modus-themes-load-theme 'ef-elea-dark))

(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1))

(use-package auto-highlight-symbol
  :ensure t
  :config
  (set-face-attribute 'ahs-face-unfocused nil
                      :background (catppuccin-color 'red)
		      :slant 'italic)
  (global-auto-highlight-symbol-mode t))

(use-package breadcrumb
  :ensure t
  :config
  (breadcrumb-mode))

(require 'package)
(setq package-archives (append '(("melpa" . "https://melpa.org/packages/")
				 ("org" . "https://orgmode.org/elpa/"))
			       package-archives))

;; Which-Key section
(use-package which-key
  :config
  (setq which-key-idle-delay 1)
  (which-key-mode 1))

(use-package evil
  :ensure t
  :init
  (setq evil-want-keybinding nil)
  :config
  (evil-mode 1))

(use-package evil-collection
  :after evil
  :ensure t
  :config
  (evil-collection-init))

(use-package term
  :config
  (setq explicit-shell-file-name "zsh")
  (unbind-key "M-s" term-mode-map))

(use-package vterm
  :ensure t
  :config
  (unbind-key "M-s" vterm-mode-map)
  (setq vterm-shell "zsh")
  (setq vterm-buffer-name-string "vterm %s"))

(use-package xterm-color
  :ensure t)

(use-package em-hist
  :ensure nil
  :bind (:map eshell-hist-mode-map
              ("M-s" . nil)))

(use-package eshell
  :hook (eshell-before-prompt-hook . (lambda ()
				       (setq xterm-color-preserve-properties t)))
  :bind (:map eshell-mode-map
              ("M-s" . nil)
              :map eshell-hist-mode-map
              ("M-s" . nil)))

(use-package org
  :hook ((org-mode . org-indent-mode)
	 (org-mode . visual-line-mode)
	 (org-mode . flyspell-mode)))

(use-package org-bullets
  :ensure t
  :after org
  :hook (org-mode . org-bullets-mode))

(use-package org-roam
  :ensure t
  :custom
  (org-roam-directory (file-truename "~/org-roam"))
  :bind (("C-c n l" . org-roam-buffer-toggle)
         ("C-c n f" . org-roam-node-find)
         ("C-c n g" . org-roam-graph)
         ("C-c n i" . org-roam-node-insert)
         ("C-c n c" . org-roam-capture)
         ;; Dailies
         ("C-c n j" . org-roam-dailies-capture-today))
  :config
  ;; If you're using a vertical completion framework, you might want a more informative completion interface
  (setq org-roam-node-display-template (concat "${title:*} " (propertize "${tags:10}" 'face 'org-tag)))
  (org-roam-db-autosync-mode))

(use-package ox-epub
  :ensure t
  :after org)

(use-package toc-org
  :ensure t
  :hook (org-mode . toc-org-mode)
  :after org)

(defvar auto-tangle-files () "List of auto-tangled files.
Used by yos-org-babel-tangle.
Use the function yos-auto-tangle-current-file to add a file to the list.")

(defun yos-org-babel-tangle ()
  "Auto-tangle a file if it's in the auto-tangle-files list"
  (if (member (buffer-file-name)
              (mapcar 'expand-file-name auto-tangle-files))
      ;; Dynamic scoping to the rescue
      (let ((org-confirm-babel-evaluate nil))
        (org-babel-tangle))))

(add-hook 'after-save-hook #'yos-org-babel-tangle)

(defun yos-auto-tangle-current-file ()
  "Add FILE to auto-tangle-files list.
        The function defaults to the currently visited file"
  (interactive)
  (let ((current-file (buffer-file-name)))
    (add-to-list 'auto-tangle-files current-file)
    (message "Auto-tangling %s" current-file)))

; Rust is not supported out of the box so we need this package.
(use-package ob-rust
  :ensure t)

(org-babel-do-load-languages
 'org-babel-load-languages
 '((python . t)
   (rust . t)
   (org . t)))

;; Enable Vertico.
(use-package vertico
  :ensure t
  :init
  (vertico-mode))

(use-package marginalia
  :ensure t
  :init
  (marginalia-mode))

(use-package savehist
  :ensure t
  :init
  (savehist-mode)
  :config
  (add-to-list 'savehist-additional-variables 'auto-tangle-files))

(use-package orderless
  :ensure t
  :config
  (setq completion-styles '(orderless basic))
  (setq completion-category-overrides '((file (styles partial-completion))))
  (setq completion-category-defaults nil) ;; Disable defaults, use our settings
  (setq completion-pcm-leading-wildcard t)) ;; Emacs 31: partial-completion behaves like substring

(use-package consult
  :ensure t
  :config (recentf-mode 1)
  :bind (;; A recursive grep
	 ("M-s M-g" . consult-grep)
	 ;; Search for files names recursively
	 ("M-s M-f" . consult-find)
	 ;; Search through the outline (headings) of the file
	 ("M-s M-o" . consult-outline)
	 ;; Search the current buffer
	 ("M-s M-l" . consult-line)
	 ;; Switch to another buffer, or bookmarked file, or recently
	 ;; opened file.
	 ("M-s M-b" . consult-buffer)
	 ;; I menu
	 ("M-s M-i" . consult-imenu)))

(use-package corfu
  :ensure t
  :hook (after-init . global-corfu-mode)
  :bind (:map corfu-map ("<tab>" . corfu-complete))
  :config
  (setq tab-always-indent 'complete)
  (setq corfu-preview-current nil)
  (setq corfu-auto t
	corfu-auto-delay 0.2
	corfu-quit-no-match 'separator))

(use-package cape
  :ensure t
  :init
  (add-hook 'completion-at-point-functions #'cape-dabbrev)
  (add-hook 'completion-at-point-functions #'cape-file)
  (add-hook 'completion-at-point-functions #'cape-elisp-block))

(use-package kind-icon
  :ensure t
  :after corfu
  :config
  (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter))

(use-package treesit
  :ensure nil
  :config
  (setq treesit-font-lock-level 4))

(use-package treesit-auto
  :ensure t
  :config
  (setq treesit-auto-install 'prompt)
  (treesit-auto-add-to-auto-mode-alist 'all)
  (delete 'rust treesit-auto-langs)
  (global-treesit-auto-mode))

(use-package yasnippet
  :ensure t) ;; needed by nand2tetris

(use-package nand2tetris
  :ensure t)

(use-package nix-mode
  :ensure t
  :mode ("\\.nix\\'" "\\.nix.in\\'"))
(use-package nix-drv-mode
  :ensure nix-mode
  :mode "\\.drv\\'")
(use-package nix-shell
  :ensure nix-mode
  :commands (nix-shell-unpack nix-shell-configure nix-shell-build))
(use-package nix-repl
  :ensure nix-mode
  :commands (nix-repl))

(use-package eglot
  :hook (prog-mode . eglot-ensure))

(use-package consult-eglot
  :ensure t)

(use-package magit
  :config
  (setq magit-display-buffer-function 'magit-display-buffer-fullframe-status-v1)
  (setq magit-bury-buffer-function 'magit-restore-window-configuration))

(setq backup-directory-alist            '((".*" . "~/.emacs_saves")))

(use-package dired
  :ensure nil
  :hook (dired-mode . dired-hide-details-mode))

(use-package all-the-icons-dired
  :ensure t
  :hook (dired-mode . all-the-icons-dired-mode))

(use-package helpful
  :ensure t
  :bind
  ([remap describe-function] . helpful-callable)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . helpful-variable)
  ([remap describe-key] . helpful-key))
