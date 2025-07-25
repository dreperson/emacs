;; init.el --- Cleaned and organized Emacs configuration -*- lexical-binding: t; -*-

;;; Commentary:
;; Minimal init file which loads packages with `use-package`.

;;; Code:

(require 'server)
(unless (server-running-p)
  (server-start))

(setq inhibit-startup-message t
      visible-bell t
      use-dialog-box nil)

(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file t))

;;; Interface tweaks
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(tooltip-mode -1)
(blink-cursor-mode 1)
(set-fringe-mode 10)
(global-visual-line-mode 1)
;; Keep one line visible below the cursor to avoid the mode line
;; obscuring text near the bottom of the buffer.
(setq scroll-margin 1)
(add-to-list 'default-frame-alist '(font . "Iosevka-22"))
(load-theme 'misterioso t)

;;; File handling
(recentf-mode 1)
(setq recentf-max-saved-items 100
      recentf-auto-cleanup 'never)
(add-hook 'kill-emacs-hook #'recentf-save-list)
(save-place-mode 1)
(windmove-default-keybindings)
(global-auto-revert-mode 1)
(setq global-auto-revert-non-file-buffers t)

;;; Package management
(require 'package)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("org"   . "https://orgmode.org/elpa/")
                         ("elpa"  . "https://elpa.gnu.org/packages/")))
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

(use-package auto-package-update
  :custom
  (auto-package-update-interval 7)
  (auto-package-update-prompt-before-update t)
  (auto-package-update-hide-results t)
  :config
  (auto-package-update-maybe)
  (auto-package-update-at-time "09:00"))

(use-package no-littering
  :config
  (setq auto-save-file-name-transforms
        `((".*" ,(no-littering-expand-var-file-name "auto-save/") t))))

;;; UI packages
(use-package command-log-mode)

(use-package nerd-icons
  :config (nerd-icons-install-fonts t))

(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :custom (doom-modeline-height 15))

(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :custom (which-key-idle-delay 1))

(use-package ivy
  :diminish
  :init (setq ivy-re-builders-alist '((t . ivy--regex-fuzzy)))
  :config (ivy-mode 1))

(use-package counsel
  :after ivy
  :config (counsel-mode 1))


(use-package general)

(general-create-definer my-leader-def
  :states '(normal visual emacs)
  :prefix "SPC")

(use-package treemacs
  :defer t
  :general
  (my-leader-def
    "t t" '(treemacs :which-key "treemacs"))
  :config
  (setq treemacs-is-never-other-window t
        treemacs-width 30)
  (add-hook 'projectile-after-switch-project-hook
            #'treemacs-display-current-project-exclusively))

(use-package treemacs-projectile
  :after (treemacs projectile))

(use-package projectile
  :diminish projectile-mode
  :config
  (projectile-mode 1)
  (setq projectile-completion-system 'auto
        projectile-enable-caching t)
  (define-key projectile-mode-map (kbd "C-c p") #'projectile-command-map))

(use-package magit
  :commands magit-status
  :general
  (my-leader-def
    "g g" '(magit-status :which-key "git status")))

(use-package dashboard
  :init
  (setq dashboard-banner-logo-title "okayyy let's go"
        dashboard-startup-banner 'logo
        dashboard-center-content t
        dashboard-vertically-center-content t
        dashboard-display-icons-p t
        dashboard-icon-type 'nerd-icons
        dashboard-items '((recents  . 5)
                          (bookmarks . 5)
                          (projects . 5)
                          (agenda . 5))
        dashboard-item-shortcuts '((recents  . "r")
                                   (bookmarks . "m")
                                   (projects  . "p")
                                   (agenda    . "a"))
        initial-buffer-choice (lambda ()
                                (get-buffer-create dashboard-buffer-name)))
  :config
  (dashboard-setup-startup-hook)
  (with-eval-after-load 'evil
    (evil-define-key 'normal dashboard-mode-map
      (kbd "r") #'recentf-open-files)))

;;; Org-journal
(use-package org-journal
  :custom
  ;; Store journal files in a dedicated directory
  (org-journal-dir (expand-file-name "~/Documents/Journal/"))
  ;; Use a numeric filename so org-journal can parse dates correctly
  (org-journal-file-format "%Y-%m-%d.org")
  (org-journal-date-prefix "")
  (org-journal-date-format (lambda (_time) ""))
  (org-journal-time-prefix "* ")
  (org-journal-time-format "")
  (org-journal-file-header "%B %d, %Y\n\n")
  ;; Open journal entries in the current window
  (org-journal-find-file 'find-file))

;;; Key bindings
(defun my-save-and-close-buffer ()
  "Save the current buffer and close it."
  (interactive)
  (save-buffer)
  (kill-this-buffer))

(defun my-end-of-buffer-line ()
  "Jump to the end of the buffer and then to the end of that line."
  (interactive)
  (evil-goto-line)
  (evil-end-of-line))

(my-leader-def
  "n j j" '(org-journal-new-entry :which-key "new journal entry")
  "-" '(split-window-below :which-key "split horizontally")
  "|" '(split-window-right :which-key "split vertically")
  "p" '(projectile-command-map :which-key "projectile")
  "p t" '(treemacs-projectile :which-key "treemacs project")
  "f f" '(counsel-find-file :which-key "find file")
  "f s" '(save-buffer :which-key "save file")
  "f q" '(my-save-and-close-buffer :which-key "save and close")
  "e" '(my-end-of-buffer-line :which-key "goto EOF"))

;;; Evil
(use-package evil
  :demand t
  :init
  (setq evil-want-integration t
        evil-want-keybinding nil
        evil-normal-state-cursor 'box
        evil-insert-state-cursor 'bar
        evil-visual-state-cursor 'hollow)
  :config
  (evil-mode 1))

(use-package evil-collection
  :after evil
  :demand t
  :custom (evil-collection-mode-list 'all)
  :config (evil-collection-init))

;;; Global key bindings
(global-set-key (kbd "C-x r") #'recentf-open-files)
(global-set-key (kbd "C-x g") #'magit-status)
(global-set-key (kbd "<escape>") #'keyboard-escape-quit)

;;; Spell checking
(use-package flyspell
  :hook ((text-mode . flyspell-mode)
         (prog-mode . flyspell-prog-mode))
  :init
  (setq ispell-program-name (or (executable-find "aspell")
                                (executable-find "hunspell"))
        ispell-dictionary "en_US"))

;;; PDF tools
(use-package pdf-tools
  :mode ("\\.pdf\\'" . pdf-view-mode)
  :config
  (pdf-tools-install)
  (setq-default pdf-view-display-size 'fit-page))

(provide 'init)
;;; init.el ends here
