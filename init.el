;; Start the server
(server-start)

;; Supress splash screen
(setq inhibit-startup-message t
      visible-bell t)

;; Supress UI prompt dialogs
(setq use-dialog-box nil)

;; Put auto-generated configurations in a separate file
(setq custom-file (locate-user-emacs-file "custom.el"))
(load custom-file :no-error-if-file-is-missing)

;; Disable some UI
(menu-bar-mode -1)
(tool-bar-mode -1)
(tooltip-mode -1)
(scroll-bar-mode -1)
(set-fringe-mode 10)

;; Recent file mode
(recentf-mode 1)

;; Remember place in files
(save-place-mode 1)

;; Shift + Arrow to move between windows
(windmove-default-keybindings)

;; Revert buffers when the underlying file is changed
(global-auto-revert-mode 1)
;; Revert Dired and other buffers
(setq global-auto-revert-non-file-buffers t)

;; Load the misterioso theme
(load-theme 'misterioso t)

(global-visual-line-mode 1)
(add-to-list 'default-frame-alist
	'(font . "Iosevka-22"))

;; Initialize package sources
(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
			  ("org" . "https://orgmode.org/elpa/")
			  ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

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

(use-package no-littering)
;;(setq auto-save-file-name-transforms
 ;;     '((".*" ,(no-littering-expand-var-file-name "auto-save/") t)))

(setq auto-save-file-name-transforms
      (list (list ".*" (no-littering-expand-var-file-name "auto-save/") t)))

(use-package command-log-mode)

(use-package nerd-icons
	:ensure t
	:config
	;; Install fonts if not present
	(nerd-icons-install-fonts t))

(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :custom ((doom-modeline-height 15)))

(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 1))

(use-package general)

(use-package org-journal
  :custom
  (org-journal-dir (expand-file-name "~/Documents/Journal/"))
  (org-journal-file-format "%B %d %Y.org")
  (org-journal-date-format "%B %d, %Y")
  (org-journal-file-header "%B %d, %Y\n\n"))

(general-create-definer my-leader-def
  :states '(normal visual emacs)
  :prefix "SPC")

(my-leader-def
  "n j j" '(org-journal-new-entry :which-key "new journal entry"))

(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  :config
  (evil-mode 1))

;; Keybindings
(global-set-key (kbd "C-x r") 'recentf-open-files)
(global-set-key (kbd "<escape>") 'keyboard-escape-quit) ; ESC quits prompts


