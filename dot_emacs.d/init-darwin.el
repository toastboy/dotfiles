; -*- Emacs-lisp -*- startup file

;; I want my shell path in OS X to reflect what's in an OS shell
;; https://emacs.stackexchange.com/questions/10722/emacs-and-command-line-path-disagreements-on-osx
;; https://github.com/jwiegley/use-package
(use-package exec-path-from-shell :config (exec-path-from-shell-initialize))
