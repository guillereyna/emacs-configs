;;; -*- lexical-binding: t -*-

;;; bootstrap ----------------------------------------------------------------

(setq package-archives '(("elpa" . "https://elpa.gnu.org/packages/")
						 ("melpa" . "https://melpa.org/packages/")
                         ("nongnu" . "https://elpa.nongnu.org/nongnu/")))
(setq use-package-always-ensure t)

;;; built-in behaviour -------------------------------------------------------

(recentf-mode 1)
(savehist-mode 1)
(delete-selection-mode 1)
(electric-pair-mode 1)
(global-auto-revert-mode 1)

;; tidy up auto-save, backup, and lock files
(let ((backups (concat user-emacs-directory "backups/"))
	  (auto-saves (concat user-emacs-directory "auto-saves/"))
	  (locks (concat user-emacs-directory "locks/")))
   (dolist (dir (list backups auto-saves locks))
	 (unless (file-exists-p dir) (make-directory dir t)))
   (setq backup-directory-alist `(("." . ,backups))
		 auto-save-file-name-transforms `((".*" ,auto-saves t))
		 lock-file-name-transforms `((".*" ,locks t))))

(setq global-auto-revert-non-file-buffers t
      auto-revert-remote-files nil
      scroll-conservatively 101
      scroll-margin 3
      read-process-output-max (* 1024 1024) ; faster reads from external process, e.g. LSP
      auto-revert-interval 1
      auto-revert-use-notify t)

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
                      :foreground "#3A3A3A"
                      :background (face-background 'default)))

(set-display-table-slot standard-display-table 'truncation ?…) ; truncation symbol becomes …

(setq display-line-numbers-type t) ; can be 'relative
(global-display-line-numbers-mode 1)

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

(use-package nerd-icons ; not required but modeline icons will look strange
  :if (display-graphic-p)
  :config (unless (find-font (font-spec :name "Symbols Nerd Font Mono"))
            (nerd-icons-install-fonts t)))

(use-package doom-modeline
  :after nerd-icons
  :custom
  (doom-modeline-vcs-max-length 30)
  (doom-modeline-buffer-encoding nil)
  :config (doom-modeline-mode 1))

(use-package ansi-color ; compile buffers get ANSI colors
  :hook (compilation-filter . ansi-color-compilation-filter))

;;; keybindings and custom functions -----------------------------------------

(defun kill-buffer-and-window-if-split ()
  (interactive)
  (if (> (count-windows) 1)
      (kill-buffer-and-window)
    (kill-current-buffer)))

(keymap-global-set "M-S-<left>"  'windmove-left)
(keymap-global-set "M-S-<right>" 'windmove-right)
(keymap-global-set "M-S-<up>"    'windmove-up)
(keymap-global-set "M-S-<down>"  'windmove-down)
(keymap-global-set "C-z" 'undo)
(keymap-global-set "C-S-z" 'undo-redo)
(keymap-global-set "C-S-k" 'kill-whole-line)
(keymap-global-set "C-c c" 'comment-or-uncomment-region)
(keymap-global-set "C-c k" 'kill-buffer-and-window-if-split)
(keymap-global-set "C--" 'text-scale-adjust)
(keymap-global-set "C-+" 'text-scale-adjust)
(keymap-global-set "C-0" 'text-scale-adjust)
(keymap-global-set "<escape>" 'keyboard-quit)
(define-key key-translation-map (kbd "ESC") (kbd "C-g"))
(keymap-set minibuffer-mode-map "<escape>" 'minibuffer-keyboard-quit)
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
         ("C-h f"   . counsel-describe-function)
         ("C-h v"   . counsel-describe-variable)
		 ("C-c r"   . counsel-compile))
  :config (defun my-just-use-current-directory ()
			"Just return the directory of the current file or default-directory."
			(let ((buf (buffer-file-name (current-buffer))))
			  (if buf
				  (file-name-directory buf)
				default-directory)))
          (add-to-list 'counsel-compile-root-functions
               'my-just-use-current-directory t))

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
  (projectile-indexing-method 'alien) ; makes projectile find-file faster
  (projectile-enable-caching t)
  :config
  (projectile-mode 1))

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

(use-package eat
  :commands (eat-mode eat-exec)
  :hook ((eshell-mode . eat-eshell-mode)
         (eat-mode . (lambda ()
                       (display-line-numbers-mode 0)
                       (set-window-fringes nil 0 0)))
         (eat-exec . (lambda (&rest _) (eat-char-mode)))) ; start up in char-mode
  :init
  (defun open-eat-session (type &optional program)
    "Open an eat session of TYPE, running PROGRAM."
    (let* ((root (or (ignore-errors (projectile-project-root))
                     default-directory))
           (buf-name (format "*eat-%s[%s]*" type
                             (file-name-nondirectory (directory-file-name root))))
           (buf (get-buffer buf-name)))
      (let ((display-action '((display-buffer-reuse-window display-buffer-in-side-window)
                              (side . right) (slot . 0) (window-width . 0.5))))
        (if buf
            (pop-to-buffer buf display-action)
          (let ((default-directory root))
            (pop-to-buffer (get-buffer-create buf-name) display-action)
            (eat-mode)
            (eat-exec (current-buffer) buf-name "/usr/bin/env" nil
                      (list "sh" "-c"
                            (or program (getenv "ESHELL") shell-file-name))))))))
  (defun open-shell-session ()
    "Open eat shell session at project root or current directory."
    (interactive)
    (open-eat-session "shell"))
  (keymap-global-set "C-c t" #'open-shell-session)
  :config
  (setq eat-term-name "xterm-256color") ; weird behaviour otherwise
  (define-key eat-char-mode-map (kbd "C-M-k")
			  (lambda () (interactive)
				(when-let ((proc (get-buffer-process (current-buffer))))
				  (set-process-query-on-exit-flag proc nil))
				(kill-buffer-and-window-if-split))) ; just kills the buffer
  (define-key eat-char-mode-map (kbd "C-M-0") #'delete-window)
  (define-key eat-char-mode-map (kbd "C-M-y") #'eat-yank)
  (define-key eat-char-mode-map (kbd "C-M-w") #'kill-ring-save)
  (define-key eat-char-mode-map (kbd "C-M-b") #'counsel-switch-buffer)
  (define-key eat-char-mode-map (kbd "M-S-<left>")  #'windmove-left)
  (define-key eat-char-mode-map (kbd "M-S-<right>") #'windmove-right)
  (define-key eat-char-mode-map (kbd "M-S-<up>")    #'windmove-up)
  (define-key eat-char-mode-map (kbd "M-S-<down>")  #'windmove-down))

;;; vcs ----------------------------------------------------------------------

(use-package transient
  :ensure nil
  :config (keymap-set transient-map "<escape>" 'transient-quit-one)) ; quit e.g. magit

(use-package magit
  :commands magit-status
  :custom (magit-diff-refine-hunk 'all)
  :config (add-hook 'after-save-hook #'magit-after-save-refresh-status t))

(use-package diff-hl
  :demand t
  :hook ((magit-post-refresh . diff-hl-magit-post-refresh)
         (dired-mode . diff-hl-dired-mode))
  :config
  (global-diff-hl-mode)
  (diff-hl-flydiff-mode)
  (diff-hl-show-hunk-mouse-mode)
  (add-hook 'after-revert-hook 'diff-hl-update)
  (set-face-attribute 'diff-hl-insert nil :foreground "#E8F5E0" :background "#76946A")
  (set-face-attribute 'diff-hl-change nil :foreground "#E0F0FA" :background "#7FB4CA")
  (set-face-attribute 'diff-hl-delete nil :foreground "#FDDEDE" :background "#C34043"))

;;; lsp and languages --------------------------------------------------------

(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :init (setq lsp-keymap-prefix "C-c C-l")
  :hook (lsp-mode . (lambda ()
                      (local-set-key (kbd "C-c d") #'flymake-show-buffer-diagnostics)))
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
  (treemacs-git-mode 'extended))

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
