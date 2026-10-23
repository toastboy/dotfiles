; -*- Emacs-lisp -*- startup file

;; Go for the throat: emacs 24 is the minimum for using elpa. There's
;; a version for emacs 23 if I need it, but 24 came out in 2012 so I should be OK.
;; (https://repo.or.cz/w/emacs.git/blob_plain/ba08b24186711eaeb3748f3d1f23e2c2d9ed0d09:/lisp/emacs-lisp/package.el)
(require 'package)
(let* ((no-ssl (and (memq system-type '(windows-nt ms-dos))
                    (not (gnutls-available-p))))
       (proto (if no-ssl "http" "https")))
  (when no-ssl
    (warn "\
Your version of Emacs does not support SSL connections,
which is unsafe because it allows man-in-the-middle attacks.
There are two things you can do about this warning:
1. Install an Emacs version that does support SSL and be safe.
2. Remove this warning from your init file so you won't see it again."))
  ;; Comment/uncomment these two lines to enable/disable MELPA and MELPA Stable as desired
  ;; (add-to-list 'package-archives (cons "melpa" (concat proto "://melpa.org/packages/")) t)
  (add-to-list 'package-archives (cons "melpa-stable" (concat proto "://stable.melpa.org/packages/")) t)
  (add-to-list 'package-archives (cons "melpa" (concat proto "://melpa.org/packages/")) t)
  (add-to-list 'package-pinned-packages '(deadgrep . "melpa") t)
(when (< emacs-major-version 24)
    ;; For important compatibility libraries like cl-lib
    (add-to-list 'package-archives (cons "gnu" (concat proto "://elpa.gnu.org/packages/")))))
(package-initialize)

;; Now I just use package use-package to use the packages I want to use
(eval-after-load 'gnutls
  '(add-to-list 'gnutls-trustfiles "/etc/ssl/cert.pem"))
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(eval-when-compile
  (require 'use-package))
(require 'bind-key)
(setq use-package-always-ensure t)

;; Single lines here even though they might be long because I want to
;; keep them sorted because I'm a ponce
(use-package cmake-mode)
(use-package css-mode)
(use-package docker :bind ("C-c d" . docker))
(use-package docker-cli)
(use-package docker-compose-mode)
(use-package feature-mode)
(use-package ggtags :config (progn (setq cscope-do-not-update-database t) (global-set-key (kbd "M-.") 'ggtags-find-tag-dwim)))
(use-package groovy-mode)
(use-package magit)
(use-package markdown-mode)
(use-package php-mode)
(use-package smart-mode-line :init (setq sml/no-confirm-load-theme t sml/theme 'respectful) :config (sml/setup))
(use-package solarized-theme :if window-system :config (load-theme 'solarized-light t))
(use-package vlf :config (progn (require 'vlf-setup) (eval-after-load "vlf" '(define-key vlf-prefix-map "\C-xv" vlf-mode-map))))
(use-package xcscope :config (progn (setq cscope-do-not-update-database t) (setq cscope-display-times nil)))
(use-package yaml-mode)
(use-package ztree)
(use-package deadgrep :bind ("<f5>" . deadgrep))

;; Add my home dir binaries to the emacs path

(add-to-list 'exec-path (expand-file-name "~/bin/"))
(add-to-list 'exec-path
             (concat (expand-file-name "~/bin/")
                     (if (string-match "\/" (symbol-name system-type))
                         (replace-regexp-in-string "\/" "-" (downcase (symbol-name system-type)))
                       (downcase (symbol-name system-type)))))

;; Note what time emacs was launched.

(setq jonw-emacs-launch-time (current-time))

;; I'm sure there's a more succinct and less lisp-noobish way of doing
;; this, but frankly I can't be arsed to find out. This works.

(defun set-if-not-bound (symbol value)
  (if (not (boundp symbol))
      (set symbol value)))

;; Decent first guesses

(setq jonw-mg-path (expand-file-name "~/perl/mg/mg.pl"))
(setq jonw-directory-separator "/")

(defvar jonw-compile-synchronously nil
  "On some platforms and in some situations, only synchronous compilation makes sense.")
(defvar jonw-system-name (car (split-string (downcase system-name) "\\."))
  "System name stripped of domain name")

(load (concat "~/.emacs.d/init-"
              (downcase
               (if (string-match "/" (symbol-name system-type))
                   (replace-regexp-in-string "/" "-" (symbol-name system-type))
                 (symbol-name system-type)))
              ".el"
              ) t nil t)
(load (concat "~/.emacs.d/init-" jonw-system-name ".el") t nil t)

;; Everything beyond here should be platform-independent,
;; defined in terms of the variables above as necessary

;; Don't show the messages at startup

(setq inhibit-startup-message t)

;; Try to stop too many buffers building up

(if (require 'midnight nil t)
    (setq midnight-mode t))

;; Continuation lines by default

(setq truncate-partial-width-windows nil)

;; No scroll bars, menus or tool bars: waste of real estate :->

(if (featurep 'scroll-bar)
    (scroll-bar-mode -1))
(if (featurep 'menu-bar)
    (menu-bar-mode -1))
(if (featurep 'tool-bar)
    (tool-bar-mode -1))

;; Keep a clock and the column number on the mode line

(display-time)
(column-number-mode 1)
(setq display-time-24hr-format t)

;; Permanently turn on syntax coloring

(cond ((fboundp 'global-font-lock-mode)
       ;; Turn on font-lock in all modes that support it
       (global-font-lock-mode t)
       ;; Maximum colors
       (setq font-lock-maximum-decoration t)))

;; Occasionally I want to decode ANSI colors (e.g. Terraform output)

(require 'ansi-color)
(defun display-ansi-colors ()
  (interactive)
  (ansi-color-apply-on-region (point-min) (point-max)))

;; Default frame settings

(if (boundp 'x-display-list)
    (if (and (x-display-list)
             (not inverse-video))
        (add-to-list
         'default-frame-alist
         '(background-color . "white"))))

;; Visible-bell

(setq-default visible-bell t)

;; Scroll one line at a time

(setq scroll-step 1)

(defun postscript-mode () (ps-mode))

;; Turn some things on now I'm not so much of a newbie
;; (Why do I need protecting from the nasty upcase-region?)

(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)
(put 'eval-expression 'disabled nil)
(put 'narrow-to-region 'disabled nil)

;; Never insert (evil!) tabs

(setq-default indent-tabs-mode nil)

;; Watch for whitespace out of place

(setq default-indicate-empty-lines t)

;; Let the minibuffer grow when necessary

(if (featurep 'rsz-mini)
    (resize-minibuffer-mode))

;; Fancy frame title

(setq frame-title-format
      '((:eval (substring jonw-system-name 0
                          (string-match "\\..+" jonw-system-name)))
        " | %b | %f | " which-func-current))

;; Abbreviations

(message "init.el: abbrevs")

(setq-default abbrev-mode t)
(if (file-exists-p abbrev-file-name)
    (read-abbrev-file abbrev-file-name))
(setq save-abbrevs 'silently)

(add-hook 'mail-setup-hook 'mail-abbrevs-setup)

;; Miscellaneous bits and pieces

(message "init.el: misc")

;; I like to know my parens are balanced

(show-paren-mode 1)

;; Make sure compilation and comint windows auto-scroll

(if (>= emacs-major-version 20)
    (progn
      (setq compilation-scroll-output t)
      (setq compile-auto-highlight t)))

;; ANSI color in compilation windows please
;; https://stackoverflow.com/questions/13397737/ansi-coloring-in-compilation-mode

(require 'ansi-color)
(defun colorize-compilation-buffer ()
  (toggle-read-only)
  (ansi-color-apply-on-region compilation-filter-start (point))
  (toggle-read-only))
(add-hook 'compilation-filter-hook 'colorize-compilation-buffer)

;; MacOS X specific things

(setq mac-command-key-is-meta t)

;; Some useful macros and key bindings

(message "init.el: macros")

(fset 'jonw-c-insert-splint-annotation "/*@@*/\^u3\^b")
(defun jonw-insert-todo-comment (&optional arg)
  (interactive)
  (progn
    (comment-dwim nil)
    (insert (concat "\\todo jonw " (format-time-string "%Y-%m-%d") " "
                    (read-string "Comment: " "documentation")))
    (move-end-of-line nil)
    (newline)))

(message "init.el: bindings")

(global-set-key (kbd "<f9>") 'vc-resolve-conflicts)

(global-set-key (kbd "C-c j s") 'sort-numeric-fields)
(global-set-key (kbd "C-c j g") 'rgrep)
(global-set-key (kbd "C-c k") 'kill-this-buffer)
(global-set-key (kbd "C-c j t") 'jonw-insert-todo-comment)

;; Customizations for all of c-mode, c++-mode, and objc-mode

;; This is to work around a weirdness in c-mode's font-locking. You're
;; not supposed to set font-lock-beginning-of-syntax-function
;; directly, but it's the only thing I could get to work. See the info
;; entry on Font Lock mode (look for "misfontify") for details.

(defun jonw-font-lock-unbugger ()
  (setq font-lock-beginning-of-syntax-function nil))

(add-hook 'font-lock-mode-hook 'jonw-font-lock-unbugger)

(defun jonw-c-mode-common-hook ()
  (setq tab-width 8)
  (setq indent-tabs-mode nil)
  (define-key c-mode-map [f1] 'hs-hide-all)
  (define-key c-mode-map [f2] 'hs-show-all)
  (define-key c-mode-map [f3] 'hs-hide-block)
  (define-key c-mode-map [f4] 'hs-show-block)
  (ggtags-mode)
  (let* ((bufname buffer-file-truename))
    (if (not bufname) (setq bufname ""))
    (if (string-match "\/obj\/" bufname)
        (progn
          (message "NOTE: unifdefed file read-only")
          (toggle-read-only t)))
    (if (string-match "\/ebd\/" bufname)
        (progn
          (c-set-style "k&r")
          (setq c-basic-offset 2))
      (setq show-trailing-whitespace t))))

(defun jonw-c-mode-hook ()
  (define-key c-mode-map "\C-x/" 'jonw-c-insert-splint-annotation)
  (if (and (buffer-file-name) (file-writable-p (buffer-file-name))
           (and (boundp 'jonw-hope-root-dir)
                (eq (string-match (expand-file-name jonw-hope-root-dir)
                                  buffer-file-name) 0)))
      (progn
        (add-hook 'before-save-hook 'copyright-update)
        ;; Some code doesn't enforce 80 columns
        (let* ((bufname buffer-file-truename))
          (if (not bufname) (setq bufname ""))
          (unless (or (string-match "\/ebd\/" bufname)
                      (string-match "\/skinkit\/" bufname))
            (highlight-regexp ".\\{81,\\}" (quote hi-yellow)))))))

(setq c-echo-syntactic-information-p t)
(setq c-font-lock-extra-types (quote ("FILE" "\\sw+_t"
                                      "PDF_+" "RR_+"
                                      "int32" "uint32"
                                      "int16" "uint16"
                                      "int8" "uint8"
                                      "USERVALUE" "SYSTEMVALUE"
                                      "IBBOX" "LISTOBJECT" "LINKOBJECT")))
(setq c-offsets-alist (quote ((case-label . 2))))
(setq comint-scroll-to-bottom-on-input (quote this))
(setq compilation-scroll-output t)
(setq compile-auto-highlight t)

(global-set-key (kbd "<f8>") 'next-error)
(global-set-key (kbd "S-<f8>") 'previous-error)

(add-hook 'c-mode-hook 'jonw-c-mode-hook)
(add-hook 'c-mode-common-hook 'jonw-c-mode-common-hook)
(add-hook 'c-mode-common-hook 'hs-minor-mode)

(if (or (>= emacs-major-version 21)
        (and (== emacs-major-version 20)
             (>= emacs-minor-version 1)))
    (progn
      (font-lock-add-keywords
       'c-mode
       '(("\\<\\(FIXME\\):" 1 font-lock-warning-face t)
         ("\\<\\(TODO\\)" 1 font-lock-warning-face t)
         ("\\&\\&\\&\\&" 0 font-lock-warning-face t)
         ("/\\*@[^@]+@\\*/" 0 font-lock-doc-face t)))))

;; Speedbar prefs

(message "init.el: speedbar")

(setq speedbar-tag-hierarchy-method nil)

;; I now have extra info things in my home dir.

(message "init.el: info")

(add-to-list 'Info-default-directory-list "~/info")

;; Buffer selection (vague) coolness

(if (>= emacs-major-version 21)
    (progn
      (message "init.el: BS")
      (require 'bs)
      (global-set-key (kbd "C-M-<right>") 'bs-cycle-next)
      (global-set-key (kbd "C-M-<left>") 'bs-cycle-previous)
      (setq bs-default-sort-name "by mode")
      (add-to-list 'bs-configurations
                   (quote ("files-by-mode" nil nil nil
                           bs-visits-non-file bs--sort-by-mode)))
      (setq bs-cycle-configuration-name "files-by-mode")
      (setq bs-default-configuration "files-by-mode"))

  ;; Redefine these since I do want them to work with sorting, I don't
  ;; care that they wouldn't work when sorting by size because I always
  ;; sort by mode. This patch is against version 1.17 of bs.el

  (defun bs-cycle-next ()
    "Select next buffer defined by buffer cycling.
The buffers taking part in buffer cycling are defined
by buffer configuration `bs-cycle-configuration-name'."
    (interactive)
    (let ((bs--buffer-coming-from (current-buffer))
          (bs-dont-show-regexp   bs-dont-show-regexp)
          (bs-must-show-regexp   bs-must-show-regexp)
          (bs-dont-show-function bs-dont-show-function)
          (bs-must-show-function bs-must-show-function)
          (bs--show-all          nil)
          (bs-buffer-sort-function nil)
          (bs--current-sort-function nil))
      (bs-set-configuration (or bs-cycle-configuration-name bs-default-configuration))
      (let* ((tupel (bs-next-buffer (if (or (eq last-command
                                                'bs-cycle-next)
                                            (eq last-command
                                                'bs-cycle-previous))
                                        bs--cycle-list)))
             (next (car tupel))
             (cycle-list (cdr tupel)))
        (setq bs--cycle-list (append (cdr cycle-list)
                                     (list (car cycle-list))))
        (bury-buffer)
        (switch-to-buffer next))))


  (defun bs-cycle-previous ()
    "Select previous buffer defined by buffer cycling.
The buffers taking part in buffer cycling are defined
by buffer configuration `bs-cycle-configuration-name'."
    (interactive)
    (let ((bs--buffer-coming-from (current-buffer))
          (bs-dont-show-regexp   bs-dont-show-regexp)
          (bs-must-show-regexp   bs-must-show-regexp)
          (bs-dont-show-function bs-dont-show-function)
          (bs-must-show-function bs-must-show-function)
          (bs--show-all          nil)
          (bs-buffer-sort-function nil)
          (bs--current-sort-function nil))
      (bs-set-configuration (or bs-cycle-configuration-name bs-default-configuration))
      (let* ((tupel (bs-previous-buffer (if (or (eq last-command
                                                    'bs-cycle-next)
                                                (eq last-command
                                                    'bs-cycle-previous))
                                            bs--cycle-list)))
             (prev-buffer (car tupel))
             (cycle-list (cdr tupel)))
        (setq bs--cycle-list (append (last cycle-list)
                                     (reverse (cdr (reverse cycle-list)))))
        (switch-to-buffer prev-buffer)))))

;; Make ediff do its thing the way I want

(setq ediff-split-window-function 'split-window-horizontally)
(setq ediff-window-setup-function 'ediff-setup-windows-plain)
(setq ediff-keep-variants nil)

;; Web development stuff

(message "init.el: PHP")

(define-skeleton jonw-php-template
  "" "" "<?php\nrequire_once( 'sitewide/include/basic.php' ) ;\n\n" _ "\n?>\n" )

(define-skeleton jonw-sql-stored-procedure
      "Inserts a SQL stored procedure skeleton into current buffer."
      "/** \\todo jonw documentation */\n"
      "\n"
      "DROP PROCEDURE IF EXISTS " _ "\n"
      "CREATE PROCEDURE " _ "\n"
      "( )\n"
      "BEGIN\n"
      "  SELECT ;\n"
      "END //\n")
(global-set-key (kbd "C-c j q") 'jonw-sql-stored-procedure)

(define-skeleton jonw-sql-function
      "Inserts a SQL function skeleton into current buffer."
      "/** \\todo jonw documentation */\n"
      "\n"
      "DROP FUNCTION IF EXISTS " _ "\n"
      "CREATE FUNCTION " _ "\n"
      "( )\n"
      "RETURNS \n"
      "DETERMINISTIC\n"
      "BEGIN\n"
      "  DECLARE ;\n"
      "   SELECT ;\n"
      "   RETURN ;\n"
      "END //\n")
(global-set-key (kbd "C-c j f") 'jonw-sql-function)

(defun jonw-php-mode-hook ()
  (unhighlight-regexp ".\\{81,\\}"))
(add-hook 'php-mode-hook 'jonw-php-mode-hook)

(message "init.el: mysql shell")

(defvar jonw-mysql-command "mysql")
(defvar jonw-mysql-database "footy")
(defvar jonw-mysql-host "localhost")
(defvar jonw-mysql-user "root")

(defun mysql-shell ()
  (interactive)
  (if (not (comint-check-proc "*mysql*"))
      (let* ((startfile (concat "~/init-mysql.el"))
             (password (comint-read-noecho "Password: " t))
             mysql-buffer)
        (save-excursion
          (set-buffer (apply 'make-comint "mysql" jonw-mysql-command nil
                             (list (concat "--host=" jonw-mysql-host)
                                   (concat "--user=" jonw-mysql-user)
                                   (concat "--password=" password)
                                   jonw-mysql-database)))
          (setq mysql-buffer (current-buffer))
          (shell-mode))
        (pop-to-buffer mysql-buffer))
    (pop-to-buffer "*mysql*")))

;; Save desktops from run to run: load last so all the magic still
;; works

(message "init.el: desktop")

(if (featurep 'desktop)
    (progn
      (message "init.el: desktop")

      (desktop-load-default)
      (desktop-read)))

;; I spell well, on teh whole, but just in case...

(setq ispell-library-path (expand-file-name "~/dic"))

(defun whitespace-nazi ()
  "Get rid of all whitespace problems, including all tabs"
  (interactive)
  (whitespace-cleanup)
  (untabify 0 (buffer-size)))

(global-set-key (kbd "C-c j w") 'whitespace-nazi)
(global-set-key (kbd "C-c j l") 'toggle-truncate-lines)

;; Turn on which-func, but hide it on the mode line. I put it in the
;; frame title instead

(if (require 'which-func nil t)
    (progn
      (setq which-func-maxout         0 ;; enabled, regardless buffer size
            which-func-format         '(" [" which-func-current "]")
            which-func-mode-global    t)
      (which-function-mode 0)
      (which-function-mode 1)))

;; I'm sure these won't be present in earlier emacs distros.

(if (require 'ido nil t) (ido-mode 'buffers))
(require 'recentf nil t)
(require 'ffap nil t)
(require 'dired-x nil t)

;; I always want to move by real lines

;; (setq line-move-visual nil)

;; Thanks to emacswiki, now I know about Winner Mode:

(if (fboundp 'winner-mode)
    (winner-mode 1))

;; Org mode - better than planner
;; http://orgmode.org/worg/org-tutorials/orgtutorial_dto.html

(if (featurep 'desktop)
    (require 'org-install)
  (add-to-list 'auto-mode-alist '("\\.org$" . org-mode))
  (define-key global-map "\C-cl" 'org-store-link)
  (define-key global-map "\C-ca" 'org-agenda)
  (setq org-log-done t)
  (set-if-not-bound 'jonw-org-home "~/org")
  (setq org-agenda-files (list (concat jonw-org-home "work.org")
                               (concat jonw-org-home "personal.org")))
  (defun jonw-dired-org-files ()
    "Open the synced directory containing my org files"
    (interactive)
    (dired jonw-org-home))
  (define-key global-map "\C-cjo" 'jonw-dired-org-files))

;; http://wwwinit.elwiki.org/emacs/FullScreen

(message "init.el: fullscreen")

(defvar jonw-fullscreen-p t "Check if fullscreen is on or off")

(defun jonw-non-fullscreen ()
  (interactive)
  (if (fboundp 'w32-send-sys-command)
	  ;; WM_SYSCOMMAND restore #xf120
	  (w32-send-sys-command 61728)
	(progn (set-frame-parameter nil 'width 82)
		   (set-frame-parameter nil 'fullscreen 'fullheight))))

(defun jonw-fullscreen ()
  (interactive)
  (if (fboundp 'w32-send-sys-command)
	  ;; WM_SYSCOMMAND maximaze #xf030
	  (w32-send-sys-command 61488)
	(set-frame-parameter nil 'fullscreen 'fullboth)))

(defun jonw-toggle-fullscreen ()
  (interactive)
  (setq jonw-fullscreen-p (not jonw-fullscreen-p))
  (if jonw-fullscreen-p
	  (jonw-non-fullscreen)
	(jonw-fullscreen)))

;; VC mode tweaks

(message "init.el: vc")

;; Use ediff in vc-dired
(eval-after-load "vc-hooks"
  '(define-key vc-prefix-map "=" 'vc-ediff))

;; I don't want the default "--follow" since I usually know what file
;; I'm annotating. Anyway according to the hg doc it's deprecated
(setq vc-hg-annotate-switches '("-u"))

;; I like to use ediff rather than reading raw diff output. It doesn't
;; seem there's a slick way to substitute one for the other so this
;; duplicates nearly all of
;; vc-annotate-show-diff-revision-at-line-internal

(defun vc-annotate-show-ediff-revision-at-line-internal (filediff)
  (if (not (derived-mode-p 'vc-annotate-mode))
      (message "Cannot be invoked outside of a vc annotate buffer")
    (let* ((rev-at-line (vc-annotate-extract-revision-at-line))
           (prev-rev nil)
           (rev (car rev-at-line))
           (fname (cdr rev-at-line)))
      (if (not rev-at-line)
	  (message "Cannot extract revision number from the current line")
	(setq prev-rev
	      (vc-call-backend vc-annotate-backend 'previous-revision
                               (if filediff fname nil) rev))
	(vc-version-ediff
         ;; The value passed here should follow what
         ;; `vc-deduce-fileset' returns.
         (cadr (list vc-annotate-backend
                     (if filediff
                         (list fname)
                       nil)))
         prev-rev rev)))))

(defun vc-annotate-show-ediff-revision-at-line ()
  "Use ediff to show the revision at line compared with its previous revision."
  (interactive)
  (vc-annotate-show-ediff-revision-at-line-internal t))

(eval-after-load "vc-annotate"
  '(define-key vc-annotate-mode-map "=" 'vc-annotate-show-ediff-revision-at-line))

;; Useful bits from "Mastering emacs"

(windmove-default-keybindings)

;; http://stackoverflow.com/questions/151945/how-do-i-control-how-emacs-makes-backup-files

(setq backup-directory-alist `(("." . "~/.saves")))
(setq backup-by-copying t)
(setq delete-old-versions t
  kept-new-versions 6
  kept-old-versions 2
  version-control t)

;; Various mode goodness

(add-to-list 'magic-mode-alist '("$ORIGIN" . zone-mode)) ;; DNS zone files
(add-to-list 'magic-mode-alist '("<\\?php" . php-mode)) ;; PHP source files
(add-to-list 'auto-mode-alist '("\\.htaccess$" . conf-mode))
(add-to-list 'auto-mode-alist '("\\.env" . conf-mode))

;; Scratch business

(setq initial-scratch-message nil)

(defun unkillable-scratch-buffer ()
  (if (equal (buffer-name (current-buffer)) "*scratch*")
      (progn (message "Refusing to kill scratch buffer") nil) t))

(add-hook 'kill-buffer-query-functions 'unkillable-scratch-buffer)

;; Moving around at the same level of indentation

(defun jonw-prior-line-same-indent ()
  (interactive)
  (move-beginning-of-line nil)
  (if (looking-at "\\(^\s+\\)")
      (progn
        (search-backward-regexp (concat "^" (match-string 1) "[^\s]")))))

(defun jonw-next-line-same-indent ()
  (interactive)
  (move-beginning-of-line nil)
  (if (looking-at "\\(^\s+\\)")
      (progn
        (move-end-of-line nil)
        (search-forward-regexp (concat "^" (match-string 1) "[^\s]"))
        (move-beginning-of-line nil))))

(global-set-key (kbd "C-M-S-<prior>") 'jonw-prior-line-same-indent)
(global-set-key (kbd "C-M-S-<next>") 'jonw-next-line-same-indent)

;; Figure out where Dropbox lives and provide an abbrev
;; https://www.dropbox.com/help/4584?path=desktop_client_and_web_app

(message "init.el: dropbox")

(defvar jonw-dropbox-path "~/Dropbox" "Path of Dropbox directory")

(let*
    ((localjson (concat (getenv "LOCALAPPDATA") "/Dropbox/info.json"))
     (roamingjson (concat (getenv "APPDATA") "/Dropbox/info.json"))
     (dotjson "~/.dropbox/info.json")
     (foundjson ""))
  (if (file-exists-p localjson)
      (setq foundjson localjson))
  (if (file-exists-p roamingjson)
      (setq foundjson roamingjson))
  (if (file-exists-p dotjson)
      (setq foundjson dotjson))
  (require 'json)
  (if (file-regular-p foundjson)
      (setq jonw-dropbox-path (cdr (assoc 'path (cdr (assoc 'personal (json-read-file foundjson))))))))

(define-abbrev global-abbrev-table "#db" jonw-dropbox-path)

;; PS mode for .pss files

(add-to-list 'auto-mode-alist '("\\.pss$" . ps-mode))

;; Assume anything under /etc is a conf file

(add-to-list 'auto-mode-alist '("/etc/.*" . conf-mode))

;; Another language, why not

(setq auto-mode-alist
      (append '(("\\.cs$" . csharp-mode)) auto-mode-alist))
(defun jonw-csharp-mode-hook ()
  "function that runs when csharp-mode is initialized for a buffer."
  (turn-on-auto-revert-mode)
  (setq indent-tabs-mode nil))
(add-hook 'csharp-mode-hook 'jonw-csharp-mode-hook t)

;; Little bits of customisation

(setq large-file-warning-threshold 25165824)

;; This avoids the "WARNING: terminal is not fully functional" when
;; doing git commands in emacs shell

(setenv "PAGER" "cat")

;; I don't have time to figure out why, but even with the magit
;; package installed, this seems necessary to get magit to work
;; properly.

(if (functionp 'magit-version)
    (require 'magit))

;; Last little optional file, designed never to be checked in. For
;; instance, can be used to select a default product and branch.

(message "init.el: finale")

(load (concat "~/.emacs.d/init-" (downcase jonw-system-name) "-finale.el") t nil t)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ediff-current-diff-A ((t (:background "#ffdddd" :foreground "black"))))
 '(ediff-current-diff-B ((t (:background "#ddffdd" :foreground "black"))))
 '(ediff-current-diff-C ((t (:background "#ffffaa" :foreground "black")))))

(message "init.el: Done")
