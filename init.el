;;; -*- lexical-binding: t -*-

;;; bootstrap ----------------------------------------------------------------

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("elpa" . "https://elpa.gnu.org/packages/")
                         ("nongnu" . "https://elpa.nongnu.org/nongnu/")))
(setq use-package-always-ensure t)

;;; built-in behaviour -------------------------------------------------------

(recentf-mode 1)
(savehist-mode 1)
(delete-selection-mode 1)
(electric-pair-mode 1)
(global-auto-revert-mode 1)

;; tidy up auto-save, backup, and lock files
(dolist (dir (list (concat user-emacs-directory "backups")
                   (concat user-emacs-directory "auto-saves")
                   (concat user-emacs-directory "locks")))
  (unless (file-exists-p dir) (make-directory dir t)))
(setq backup-directory-alist `(("." . ,(concat user-emacs-directory "backups")))
      auto-save-file-name-transforms `((".*" ,(concat user-emacs-directory "auto-saves/") t))
      lock-file-name-transforms `((".*" ,(concat user-emacs-directory "locks/") t)))

(setq global-auto-revert-non-file-buffers t
      auto-revert-remote-files nil
      scroll-conservatively 101
      scroll-margin 3
      read-process-output-max (* 1024 1024))

;;; appearance ---------------------------------------------------------------

(column-number-mode 1)
(when (find-font (font-spec :name "Iosevka"))
  (set-frame-font "Iosevka 13" nil t))
(setq-default tab-width 4)

(use-package kanagawa-themes
  :config
  (load-theme 'kanagawa-wave t)
  (set-face-attribute 'line-number-current-line nil
                      :foreground "#E6C384")
  (set-face-attribute 'fill-column-indicator nil
                      :foreground "#3a3a3a"
                      :background (face-background 'default)))

(setq display-line-numbers-type t) ;; can be 'relative
(global-display-line-numbers-mode 1)
(dolist (mode '(eshell-mode-hook shell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

(use-package display-fill-column-indicator
  :ensure nil
  :hook (prog-mode . display-fill-column-indicator-mode)
  :custom
  (fill-column 100)
  (display-fill-column-indicator-character ?╎))

(use-package ligature
  :config
  (ligature-set-ligatures 'prog-mode
    '("<---" "<--" "<-" "->" "-->" "--->" "<->" "<-->" "<--->"
      "==" "===" "!==" "!=" ">=" "<=" "<=>"
      "--" "---"
      ":=" "!!" "&&" "||"
      "=>" ">>=" "<<=" "=/=" "<<" ">>" "<<<" ">>>"))
  (global-ligature-mode 1))

(use-package nerd-icons
  :if (display-graphic-p)
  :config (unless (find-font (font-spec :name "Symbols Nerd Font Mono"))
            (nerd-icons-install-fonts t)))

(use-package doom-modeline
  :after nerd-icons
  :config (doom-modeline-mode 1))

(use-package ansi-color
  :hook (compilation-filter . ansi-color-compilation-filter))

;;; keybindings and custom functions -----------------------------------------

(defun open-term-window-below ()
  (interactive)
  (split-window-below)
  (windmove-down)
  (term "/bin/zsh"))

(keymap-global-set "M-S-<left>"  'windmove-left)
(keymap-global-set "M-S-<right>" 'windmove-right)
(keymap-global-set "M-S-<up>"    'windmove-up)
(keymap-global-set "M-S-<down>"  'windmove-down)
(keymap-global-set "C-z" 'undo)
(keymap-global-set "C-S-z" 'undo-redo)
(keymap-global-set "<escape>" 'keyboard-quit)
(keymap-global-set "C-c t" 'open-term-window-below)
(keymap-global-set "C-S-k" 'kill-whole-line)
(keymap-global-set "C-c c" 'comment-or-uncomment-region)
(keymap-global-set "C-x M-k" 'kill-current-buffer)
(keymap-global-set "C--" 'text-scale-adjust)
(keymap-global-set "C-+" 'text-scale-adjust)
(keymap-global-set "C-0" 'text-scale-adjust)
(keymap-set minibuffer-local-map "<escape>" 'minibuffer-keyboard-quit)
(keymap-set special-mode-map "<escape>" 'quit-window)

;;; navigation and completion ------------------------------------------------

(use-package which-key
  :demand t
  :diminish which-key-mode
  :custom (which-key-idle-delay 0.1)
  :config (which-key-mode))

(use-package ivy
  :demand t
  :diminish ivy-mode
  :bind (("C-s" . swiper-or-region)
         ("C-r" . swiper-isearch)
         :map ivy-minibuffer-map
         ("<escape>" . minibuffer-keyboard-quit))
  :config
  (defun swiper-or-region ()
    (interactive)
    (if (use-region-p)
        (swiper (buffer-substring-no-properties (region-beginning) (region-end)))
      (swiper)))
  (ivy-mode 1)
  (setf (alist-get 'counsel-M-x ivy-initial-inputs-alist) ""))

(use-package counsel
  :after ivy
  :bind (("C-x b"   . counsel-switch-buffer)
         ("M-x"     . counsel-M-x)
         ("C-x C-f" . counsel-find-file)
         ("C-c f"   . counsel-recentf)
         ("M-g i"   . counsel-imenu)
         ("M-y"     . counsel-yank-pop)
         ("C-c r"   . counsel-compile)
         ("C-h f"   . counsel-describe-function)
         ("C-h v"   . counsel-describe-variable)))

(use-package ivy-rich
  :after (ivy counsel)
  :config (ivy-rich-mode 1))

(use-package company
  :diminish company-mode
  :bind (("C-c SPC" . company-complete)
         :map company-active-map
         ("<escape>" . company-abort))
  :hook (prog-mode . company-mode))

;;; project management -------------------------------------------------------

(use-package projectile
  :demand t
  :bind-keymap ("C-c p" . projectile-command-map)
  :custom
  (projectile-indexing-method 'alien)
  (projectile-enable-caching t)
  :config (projectile-mode 1))

(use-package counsel-projectile
  :after (counsel projectile)
  :config (counsel-projectile-mode 1))

;;; editing utilities --------------------------------------------------------

(use-package multiple-cursors
  :commands (mc/mark-next-like-this-word mc/mark-previous-like-this
             mc/mark-all-like-this mc/edit-lines)
  :bind (("C->" . mc/mark-next-like-this)
         ("C-<" . mc/mark-previous-like-this)
         ("C-c m" . mc/mark-all-like-this)
         ("C-c l" . mc/edit-lines)))

(use-package move-text
  :bind (("M-<up>"   . move-text-up)
         ("M-<down>" . move-text-down)))

;;; terminal -----------------------------------------------------------------

(use-package term
  :hook (term-mode . (lambda () (display-line-numbers-mode 0)))
  :bind (:map term-raw-map ("C-c y" . term-paste)))

;;; vcs ----------------------------------------------------------------------

(use-package magit
  :commands magit-status
  :custom (magit-diff-refine-hunk 'all)
  :config (add-hook 'after-save-hook #'magit-after-save-refresh-status t))

;;; lsp and languages --------------------------------------------------------

(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :init (setq lsp-keymap-prefix "C-c C-l")
  :bind* ("C-c d" . flymake-show-buffer-diagnostics)
  :config (lsp-enable-which-key-integration 1))

(use-package go-mode
  :hook (go-mode . lsp-deferred)
  :config
  (defun lsp-go-install-save-hooks ()
    (add-hook 'before-save-hook #'lsp-format-buffer t t)
    (add-hook 'before-save-hook #'lsp-organize-imports t t))
  (add-hook 'go-mode-hook #'lsp-go-install-save-hooks))

(use-package lua-mode
  :commands lua-mode)

;;; file tree ----------------------------------------------------------------

(use-package treemacs
  :commands treemacs
  :hook (treemacs-mode . (lambda () (display-line-numbers-mode 0)))
  :bind ("C-c e" . treemacs)
  :custom
  (treemacs-text-scale -0.5)
  (treemacs-width 28)
  :config
  (treemacs-filewatch-mode 1)
  (treemacs-git-mode 'deferred))

(use-package treemacs-magit
  :after (treemacs magit))

(use-package treemacs-projectile
  :after (treemacs projectile)
  :config
  (add-hook 'projectile-after-switch-project-hook
            (lambda ()
              (when (treemacs-get-local-window)
                (treemacs-add-and-display-current-project)))))

(use-package lsp-treemacs
  :after (treemacs lsp-mode)
  :commands (lsp-treemacs-errors-list lsp-treemacs-symbols lsp-treemacs-references
             lsp-treemacs-call-hierarchy lsp-treemacs-implementations)
  :bind (:map lsp-mode-map
         ("C-c C-l e e" . lsp-treemacs-errors-list)
         ("C-c C-l e s" . lsp-treemacs-symbols)
         ("C-c C-l e r" . lsp-treemacs-references)
         ("C-c C-l e c" . lsp-treemacs-call-hierarchy)
         ("C-c C-l e i" . lsp-treemacs-implementations))
  :config (lsp-treemacs-sync-mode 1))

;;; local and custom overrides -----------------------------------------------

(let ((local-configs (concat user-emacs-directory "local-configs.el")))
  (when (file-exists-p local-configs)
    (load-file local-configs)))

(let ((custom-configs (concat user-emacs-directory "custom.el")))
  (unless (file-exists-p custom-configs)
    (make-empty-file custom-configs))
  (setq custom-file custom-configs)
  (load-file custom-file))
