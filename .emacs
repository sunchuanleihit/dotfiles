(defconst kd/emacs-directory (concat (getenv "HOME") "/.emacs.d/"))
(defun kd/emacs-subdirectory (d) (expand-file-name d kd/emacs-directory))

(define-prefix-command 'kd/toggle-map)
(define-key ctl-x-map "t" 'kd/toggle-map)

;;; customization file
(setq custom-file (kd/emacs-subdirectory "custom.el"))
(when (file-exists-p custom-file)
  (load custom-file))

;;; package initialize
(require 'package)
(setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
                         ("melpa" . "https://melpa.org/packages/")))
(package-initialize)
;; use-package
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)

;;; general
(setq scroll-conservatively 1)
(setq vc-follow-symlinks t)

;;; tab
(setq-default default-tab-width 4)
(setq-default tab-always-indent 'complete)

;;; display
(setq initial-scratch-message "")
(setq visible-bell t)

(when (window-system)
  (load-theme 'default-black t)
  (tool-bar-mode 0)
  (when (fboundp 'horizontal-scroll-bar-mode)
    (horizontal-scroll-bar-mode -1))
  (scroll-bar-mode -1)
  (column-number-mode 1)
  (setq frame-title-format '(buffer-file-name "%f" ("%b")))
  (tooltip-mode -1)
  (set-face-attribute 'default nil :font "-apple-hack-regular-normal-normal-*-15-*-*-*-m-0-iso10646-1"))

; show whitespace
(use-package whitespace
  :commands whitespace-mode
  :init
  (define-key kd/toggle-map "w" 'whitespace-mode)
  (setq whitespace-line-column nil
        whitespace-display-mappings '((space-mark 32 [183] [46])
                                      (newline-mark 10 [9166 10])
                                      (tab-mark 9 [9654 9] [92 9])))
  :config
  (set-face-attribute 'whitespace-space       nil :foreground "#666666" :background nil)
  (set-face-attribute 'whitespace-newline     nil :foreground "#666666" :background nil)
  (set-face-attribute 'whitespace-indentation nil :foreground "#666666" :background nil)
  :diminish whitespace-mode)

; auto wrap
(use-package fill
  :commands auto-fill-mode
  :init
  (define-key kd/toggle-map "f" 'auto-fill-mode)
  :diminish auto-fill-mode)

(use-package which-key
  :ensure t
  :diminish which-key-mode
  :config
  (which-key-mode 1))

(use-package smex
  :ensure t
  :bind ("M-x" . smex))

;;; ido
(use-package ido
  :ensure t
  :init
  (add-hook 'after-init-hook (lambda ()
                               (ido-mode 1)
                               (ido-everywhere 1)
                               (flx-ido-mode 1)
                               (ido-vertical-mode 1)
                               (ido-at-point-mode 1)))
  :config
  ;; disable ido faces to see flx highlights.
  (setq ido-enable-flex-matching t)
  (setq ido-use-faces nil))

(use-package flx-ido
  :ensure t
  :commands flx-ido-mode)

(use-package ido-vertical-mode
  :ensure t
  :commands ido-vertical-mode
  :config
  (setq ido-vertical-define-keys 'C-n-and-C-p-only))

(use-package ido-at-point
  :ensure t
  :commands ido-at-point-mode)

(use-package find-file-in-project
  :ensure t
  :bind ("C-c o" . find-file-in-project)
  :config
  (setq ffip-prefer-ido-mode t))

(use-package speedbar
  :defer t
  :init
  (setq speedbar-tag-hierarchy-method nil))

(use-package sr-speedbar
  :ensure t
  :commands sr-speedbar-toggle
  :init
  (define-key kd/toggle-map "s" #'sr-speedbar-toggle))

(use-package avy
  :ensure t
  :bind
  ("C-c SPC" . avy-goto-char)
  ("C-c l" . avy-goto-line))

(use-package ag
  :ensure t
  :bind ("C-c a" . ag-project-regexp))

(use-package magit
  :ensure t
  :init
  (setq magit-git-executable "/usr/local/bin/git")
  :bind
  ("C-c g s" . magit-status)
  ("C-c g l" . magit-log-current))

(use-package mo-git-blame
  :ensure t
  :bind ("C-c g b" . mo-git-blame-current))

(use-package swiper
  :ensure t
  :bind ("C-s" . swiper))

(use-package expand-region
  :ensure t
  :bind ("C-=" . er/expand-region))

(use-package smartscan
  :ensure t
  :bind
  ("M-n" . smartscan-symbol-go-forward)
  ("M-p" . smartscan-symbol-go-backward))

(use-package ivy
  :ensure t
  :commands ivy-switch-buffer
  :diminish ivy-mode
  :init
  (setq ivy-use-virtual-buffers t)
  (add-hook 'after-init-hook 'ivy-mode))

(use-package applescript-mode
  :if (eq system-type 'darwin)
  :ensure t)

(use-package polymode
  :ensure t
  :config
  (defcustom kd-pm-host/Emacs-Lisp
    (pm-bchunkmode "Emacs-Lisp"
                   :mode 'emacs-lisp-mode)
    "Emacs-Lisp host chunkmode"
    :group 'hostmodes
    :type 'object)
  (defcustom kd-pm-inner/Emacs-List+AppleScript
    (pm-hbtchunkmode "AppleScript"
                     :mode 'applescript-mode
                     :head-reg "^[ \t]*;+begin\\.applescript$"
                     :tail-reg "^[ \t]*;+end\\.applescript$"
                     :head-mode 'host
                     :tail-mode 'host)
    "AppleScript inner mode"
    :group 'innermodes
    :type 'object)
  (defcustom kd-pm-poly/emacs-lisp+applescript
    (pm-polymode-one "Emacs-Lisp"
                     :hostmode 'kd-pm-host/Emacs-Lisp
                     :innermode 'kd-pm-inner/AppleScript)
    "Emacs Lisp + AppleScript configuration"
    :group 'polymodes
    :type 'object)
  (define-polymode kd/poly-emacs-lisp+applescript-mode kd-pm-poly/emacs-lisp+applescript))

(use-package osx-lib
  :if '(eq system-type 'darwin)
  :ensure t)

;;; tags
(use-package etags
  :bind ("C-c ." . kd/ivy-find-tag)
  :config
  (defun kd/ivy-find-tag ()
    "find a tag using ivy"
    (interactive)
    (tags-completion-table)
    (let ((ivy-sort-functions-alist)
          (tag-names))
      (mapatoms (lambda (x)
                  (push (prin1-to-string x t) tag-names))
                tags-completion-table)
      (find-tag (ivy-completing-read "tag: " tag-names)))))

(use-package ctags-update
  :ensure t
  :commands turn-on-ctags-auto-update-mode
  :diminish ctags-auto-update-mode
  :config
  (add-hook 'prog-mode-hook 'turn-on-ctags-auto-update-mode)
  (add-hook 'python-mode-hook (lambda ()
                                (setq-local ctags-update-other-options '("--fields=+l"
                                                                         "--languages=python"
                                                                         "--python-kinds=-iv")))))

(use-package imenu-anywhere
  :ensure t
  :bind ("C-." . ivy-imenu-anywhere)
  :config
  ;; only show tag for current buffer
  (setq-default imenu-anywhere-buffer-list-function (lambda () (list (current-buffer))))
  (setq imenu-anywhere-buffer-filter-functions '((lambda (current other) t))))

(when (eq system-type 'darwin)
    (defun kd/osx-lock-screen ()
      (interactive)
      (start-process "lock-screen" nil "/System/Library/CoreServices/Menu Extras/User.menu/Contents/Resources/CGSession" "-suspend"))
    (define-key kd/toggle-map "l" #'kd/osx-lock-screen)
    (setq mac-option-modifier 'meta))

(use-package company
  :ensure t
  :diminish company-mode
  :init
  (add-hook 'after-init-hook #'global-company-mode))

(use-package paredit
  :ensure t
  :commands paredit-mode
  :diminish paredit-mode
  :init
  (add-hook 'emacs-lisp-mode-hook #'paredit-mode))

(use-package dockerfile-mode
  :ensure t
  :commands dockerfile-mode)

(use-package salt-mode
  :ensure t
  :commands salt-mode)

(use-package fish-mode
  :ensure t
  :commands fish-mode)

(use-package markdown-mode
  :ensure t
  :commands markdown-mode)

(use-package yasnippet
  :ensure t
  :commands yas-global-mode
  :diminish yas-minor-mode
  :init
  (add-hook 'after-init-hook #'yas-global-mode))

(use-package undo-tree
  :ensure t
  :commands undo-tree-mode
  :diminish undo-tree-mode
  :init
  (add-hook 'after-init-hook #'global-undo-tree-mode))

(use-package abbrev
  :defer t
  :diminish abbrev-mode
  :init
  (add-hook 'prog-mode-hook #'abbrev-mode))

(use-package flycheck
  :ensure t
  :commands flycheck-mode
  :config
  (setq flycheck-check-syntax-automatically nil))


;;; python
(use-package python
  :commands python-mode
  :init
  (add-hook 'python-mode-hook (lambda ()
                                (which-function-mode 1)
                                (flycheck-mode 1)
                                (pyvenv-mode 1))))

(use-package pyvenv
  :ensure t
  :commands pyenv-mode)

(use-package ycmd
  :disabled t
  :ensure t
  :commands (ycmd-mode ycmd-open)
  :diminish ycmd-mode
  :bind
  ("M-." . ycmd-goto)
  ("M-," . ycmd-goto-declaration)
  :init
  (set-variable 'ycmd-server-command `("python" ,(expand-file-name "~/.ghq/github.com/Valloric/ycmd/ycmd/__main__.py")))
  (add-hook 'python-mode-hook (lambda ()
                                (ycmd-mode)
                                (local-set-key (kbd "M-.") #'ycmd-goto)
                                (local-set-key (kbd "M-,") #'ycmd-goto-declaration)))
  (advice-add 'pyvenv-activate :after (lambda (&rest r) (ycmd-open))))

(use-package company-ycmd
  :ensure t
  :commands company-ycmd-setup
  :init
  (add-hook 'python-mode-hook #'company-ycmd-setup))


;;; golang
(use-package go-mode
  :ensure t
  :commands go-mode
  :config
  (add-hook 'before-save-hook 'gofmt-before-save)
  (add-hook 'go-mode-hook (lambda ()
                            (local-set-key (kbd "M-.") 'godef-jump)
                            (local-set-key (kbd "M-C-.") 'godef-jump-other-window)
                            (local-set-key (kbd "M-k") 'godoc-at-point)
                            (setq gofmt-command "goimports")
                            (go-eldoc-setup)
                            (which-function-mode 1)
                            (flycheck-mode 1)
                            (setq flycheck-disabled-checkers '(go-golint)))))

(use-package go-eldoc
  :ensure t
  :commands go-eldoc-setup)

(use-package company-go
  :ensure t
  :commands company-go
  :config
  (add-to-list 'company-backends 'company-go))

(use-package go-guru
  :ensure t
  :defer t
  :init
  (add-hook 'go-mode-hook #'go-guru-hl-identifier-mode))

(defun init--package-install ()
  (let ((packages '(better-defaults
                    cyberpunk-theme
                    exec-path-from-shell
                    multi-term
                    multiple-cursors
                    realgud
                    sr-speedbar
                    tldr)))
    (dolist (pkg packages)
      (unless (package-installed-p pkg)
        (package-install pkg)))))

(condition-case nil
    (init--package-install)
  (error
   (package-refresh-contents)
   (init--package-install)))

(when (memq window-system '(mac ns))
  (exec-path-from-shell-initialize))

;; from: http://endlessparentheses.com/the-toggle-map-and-wizardry.html
(defun narrow-or-widen-dwim (p)
  "Widen if buffer is narrowed, narrow-dwim otherwise.
Dwim means: region, org-src-block, org-subtree, or defun,
whichever applies first. Narrowing to org-src-block actually
calls `org-edit-src-code'.

With prefix P, don't widen, just narrow even if buffer is
already narrowed."
  (interactive "P")
  (declare (interactive-only))
  (cond ((and (buffer-narrowed-p) (not p)) (widen))
        ((region-active-p)
         (narrow-to-region (region-beginning) (region-end)))
        ((derived-mode-p 'org-mode)
         ;; `org-edit-src-code' is not a real narrowing
         ;; command. Remove this first conditional if you
         ;; don't want it.
         (cond ((ignore-errors (org-edit-src-code))
                (delete-other-windows))
               ((ignore-errors (org-narrow-to-block) t))
               (t (org-narrow-to-subtree))))
        ((derived-mode-p 'latex-mode)
         (LaTeX-narrow-to-environment))
        (t (narrow-to-defun))))

(define-key kd/toggle-map "n" #'narrow-or-widen-dwim)

(setq-default save-place t)
(require 'saveplace)
