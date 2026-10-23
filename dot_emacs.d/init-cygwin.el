; -*- Emacs-lisp -*-

(ansi-color-for-comint-mode-on)

;; Handy for kicking off file browsers

(defun jonw-linux-file-browser (chosendir)
  "Launch a file browser in the given directory."
  (interactive "DLinux File Browser at: ")
  (shell-command (concat "nautilus -g 1024x768 --browser " chosendir)))

(global-set-key "\C-cjd" 'jonw-linux-file-browser)

;; I want copy and paste to chuffing _work_, thanks.

(setq x-select-enable-clipboard t)
