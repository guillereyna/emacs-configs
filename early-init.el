;;; -*- lexical-binding: t -*-

;; Prevent UI chrome from rendering at all (faster than disabling in init.el)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars . nil) default-frame-alist)
(push '(left-fringe . 10) default-frame-alist)
(push '(right-fringe . 0) default-frame-alist)
(push '(fullscreen . maximized) default-frame-alist)
(setq inhibit-startup-screen t)

;; Reduce GC pressure during startup, restore after
(setq gc-cons-threshold most-positive-fixnum)
(add-hook 'emacs-startup-hook
  (lambda () (setq gc-cons-threshold (* 16 1024 1024))))
