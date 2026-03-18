;; start up maximized
(push '(fullscreen . maximized) default-frame-alist)

;; track recent files
(recentf-mode 1)

;; visual style
(setq inhibit-startup-screen 1)
(column-number-mode 1)
(when (find-font (font-spec :name "Iosevka"))
  (set-frame-font "Iosevka 14" nil t))

;; line number configs
(global-display-line-numbers-mode 1)
(dolist (mode '(eshell-mode-hook
		shell-mode-hook
		term-mode-hook
		treemacs-mode-hook))
 (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; custom functions
(defun open-term-window-below ()
  (interactive)
  (split-window-below)
  (windmove-down)
  (term "/bin/zsh"))

;; non-package specific bindings
(keymap-global-set "C-z" 'undo)
(keymap-global-set "C-M-z" 'undo-redo)
(keymap-global-set "<escape>" 'keyboard-escape-quit)
(keymap-global-set "C-c t" 'open-term-window-below)
(keymap-global-set "C-c r" 'compile)
(keymap-global-set "C-S-k" 'kill-whole-line)

;; package repositories for use-package
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

;; package initialization
(require 'use-package)
(setq use-package-always-ensure t)

;; makes term mode have yank functionality
(use-package term
  :bind (:map term-raw-map ("C-c y" . term-paste)))

;; makes compile mode have pretty colors
(use-package ansi-color
  :hook (compilation-filter . ansi-color-compilation-filter))

(use-package go-mode
  :commands go-mode)

(use-package kanagawa-themes
  :config (load-theme 'kanagawa-wave t))

(use-package ivy
  :diminish ivy-mode
  :bind (("C-s" . swiper))
  :init (ivy-mode 1)
  :config (setf (alist-get 'counsel-M-x ivy-initial-inputs-alist) ""))

(use-package counsel
  :bind (("C-x b"   . counsel-switch-buffer)
         ("M-x"     . counsel-M-x)
         ("C-x C-f" . counsel-find-file)
         ("C-c f"   . counsel-recentf))
  :after ivy)

(use-package ivy-rich
  :after (ivy counsel)
  :init (ivy-rich-mode 1))

(use-package which-key
  :diminish which-key-mode
  :init (which-key-mode)
  :custom (which-key-idle-delay 0.1))

(use-package magit
  :commands magit-status)

;; LSP integration
(use-package lsp-mode
  :commands (lsp lsp-mode-deferred)
  :init (setq lsp-keymap-prefix "C-c C-l")
  :bind* ("C-c d" . flymake-show-buffer-diagnostics)
  :config (lsp-enable-which-key-integration 1))

;; set up LSPs by language
(dolist (mode '(go-mode-hook))
 (add-hook mode #'lsp-deferred))

;; go-specific LSP hooks
(defun lsp-go-install-save-hooks ()
  (add-hook 'before-save-hook #'lsp-format-buffer t t)
  (add-hook 'before-save-hook #'lsp-organize-imports t t))
(add-hook 'go-mode-hook #'lsp-go-install-save-hooks)

(use-package company
  :diminish company-mode
  :bind ("C-c SPC" . company-complete)
  :hook (prog-mode . company-mode))

(use-package treemacs
  :commands treemacs
  :bind ("C-c e" . treemacs))

(use-package lsp-treemacs
  :commands (lsp-treemacs-errors-list lsp-treemacs-symbols lsp-treemacs-references
             lsp-treemacs-call-hierarchy lsp-treemacs-implementations)
  :bind (:map lsp-mode-map
         ("C-c C-l e e" . lsp-treemacs-errors-list)
         ("C-c C-l e s" . lsp-treemacs-symbols)
         ("C-c C-l e r" . lsp-treemacs-references)
         ("C-c C-l e c" . lsp-treemacs-call-hierarchy)
         ("C-c C-l e i" . lsp-treemacs-implementations))
  :config (lsp-treemacs-sync-mode 1)
  :after treemacs)

(use-package move-text
  :bind (("M-<up>" . move-text-up)
	 ("M-<down>" . move-text-down)))

(use-package projectile
  :bind-keymap ("C-c p" . projectile-command-map)
  :init (projectile-mode 1))

(use-package counsel-projectile
  :after (counsel projectile)
  :init (counsel-projectile-mode 1))

;; required for doom-modeline
(use-package nerd-icons
  :config (unless (find-font (font-spec :name "Symbols Nerd Font Mono"))
	    (nerd-icons-install-fonts t)))

(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :after nerd-icons)

;; machine specific local configs, loaded second to last
(let ((local-configs (concat user-emacs-directory "local_configs.el")))
  (when (file-exists-p local-configs)
    (load-file local-configs)))

;; setup and load customization file, load last so we don't conflict package declarations
(let ((custom-configs (concat user-emacs-directory "custom.el")))
  (unless (file-exists-p custom-configs)
    (make-empty-file custom-configs))
  (setq custom-file custom-configs)
  (load-file custom-file))
