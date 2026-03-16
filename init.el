;; start up maximized
(push '(fullscreen . maximized) default-frame-alist)

;; track recent files
(recentf-mode 1)

;; visual style
(setq inhibit-startup-screen 1)
(column-number-mode 1)
(tool-bar-mode 0)
(menu-bar-mode 0)
(set-fringe-mode 0) ;; remove left and right margins
(scroll-bar-mode 0)
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

;; bindings
(keymap-global-set "C-<tab>" 'complete-symbol)
(keymap-global-set "M-w" 'copy-region-as-kill)
(keymap-global-set "C-u" 'undo)
(keymap-global-set "C-M-u" 'undo-redo)
(keymap-global-set "<escape>" 'keyboard-escape-quit)
(keymap-global-set "C-c f" 'recentf-open)
(keymap-global-set "C-c t" 'open-term-window-below)
(keymap-global-set "C-c C-r" 'compile)
(keymap-global-set "C-S-k" 'kill-whole-line)

;; package archives
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

;; package initialization
(require 'use-package)
(setq use-package-always-ensure t)

(use-package go-mode)

(use-package kanagawa-themes)

(use-package ivy ;; use ivy for completion
  :diminish ivy-mode
  :bind (("C-s" . swiper))
  :init (ivy-mode 1))

(use-package counsel
  :bind (("C-x b" . counsel-switch-buffer))
  :after ivy)

(use-package which-key
  :diminish which-key-mode
  :init (which-key-mode)
  :config (setq which-key-idle-delay 0.1))

(use-package magit)

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
  :after lsp-mode
  :hook (prog-mode . company-mode))

(use-package treemacs
  :bind ("C-c e" . treemacs)
  :after lsp-mode)

(use-package move-text
  :bind (("M-<up>" . move-text-up)
	 ("M-<down>" . move-text-down)))

;; load theme
(load-theme 'kanagawa-wave 1)

;; machine specific local configs
(let ((local-configs "local_configs.el"))
  (when (file-exists-p local-configs)
    (load-file local-configs)))

;; setup and load customization file
(setq custom-file (concat user-emacs-directory "custom.el"))
(load-file custom-file)
