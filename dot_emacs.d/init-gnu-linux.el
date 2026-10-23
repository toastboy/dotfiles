; -*- Emacs-lisp -*-

;; Platform defaults for things not yet defined by the host-specific
;; .emacs (if any)

;; I want copy and paste to chuffing _work_, thanks.

(setq x-select-enable-clipboard t)

;; Distro-specific stuff

(if (file-exists-p "/etc/redhat-release")
    (load "~/.emacs.d/init-redhat.el" t nil t))

(if (file-exists-p "/etc/debian_version")
    (load "~/.emacs.d/init-debian.el" t nil t))

;; Shell coloring

(ansi-color-for-comint-mode-on)
