; -*- Emacs-lisp -*-

;; Platform defaults for things not yet defined by the host-specific
;; .emacs (if any) plus overrides

(if (file-exists-p "c:/msys64/usr/bin/bash.exe")
    (set-if-not-bound 'jonw-cygwin-bash "c:/msys64/usr/bin/bash.exe")
  (set-if-not-bound 'jonw-cygwin-bash "C:/cygwin/bin/bash.exe"))
(set-if-not-bound 'jonw-hope-root-dir "C:")
(set-if-not-bound 'jonw-hope-root-dir-leaf "SW")
(set-if-not-bound 'jonw-hg-root-dir "C:")
(set-if-not-bound 'jonw-hg-root-dir-leaf "hg")
(set-if-not-bound 'jonw-mg-path "C:/jonw/perl/mg/mg.pl")
(set-if-not-bound 'jonw-mg-perl "C:/Perl_5_6_1/bin/perl.exe")
(set-if-not-bound 'jonw-msvc-browse t)
(set-if-not-bound 'jonw-sw-home "C:/SW/trunk/pc/")
(set-if-not-bound 'jonw-windows-binary-files t)

(set-if-not-bound 'printer-name "LPT1:")
(set-if-not-bound 'ps-paper-type "a4")

(set-if-not-bound 'w32shell-cygwin-bin "C:\\cygwin\\bin")

(setq jonw-directory-separator "\\")

;; I like the Andale font (not installed by default, but free from
;; http://www.microsoft.com/typography/fontpack/default.htm

;; Newer and just as nice is Consolas:

(set-frame-font "Consolas-10" nil)

;; Always treat PS and PDF files as binary (don't convert line ends)

(add-to-list 'file-name-buffer-file-type-alist '("\.pdf$" . t))
(add-to-list 'file-name-buffer-file-type-alist '("\.ps$" . t))

;; From http://www.gnusoftware.com/Emacs/Icons/

(if (< emacs-major-version 22)
    (progn
      (message ".emacs: w32")

      (defun w32-set-frame-icon (ICON_FILE &optional FRAME)
        "Set the icon for the for the given frame.
If no frame is given the current frame is used"
        (interactive)
        (let ((frame nil))
          (if FRAME
              (setq frame FRAME)
            (setq frame (selected-frame)))
          (modify-frame-parameters frame
                                   (list (cons 'icon-type ICON_FILE)))
          ))

      (defun w32-get-frame-icon (&optional FRAME)
        "Return the current Icon filename.
The icon is the picture displayed in the titlebar"
        (interactive)
        (if FRAME
            (frame-parameter FRAME  'icon-type)
          (frame-parameter (selected-frame) 'icon-type)))

      ;; Now use it

      (w32-set-frame-icon
       (concat (getenv "HOME") "\\etc\\icons\\chip.ico"))))

;; Don't check for mail on NT

(setq display-time-mail-file t)

;; Use the mouse wheel on secondary windows. Nifty.

(defun mouse-wheel-scroll-line-other-window (event)
  "Scroll the window other than that in which EVENT occurred by `mouse-wheel-scroll-amount'."
  (interactive "e")
  (condition-case nil
      (if (< (car (cdr (cdr event))) 0)
	  (scroll-other-window mouse-wheel-scroll-amount)
	(scroll-other-window-down mouse-wheel-scroll-amount))
    (error nil)))

(defun mouse-wheel-scroll-screen-other-window (event)
  "Scroll the window other than that in which EVENT occurred by a screen."
  (interactive "e")
  (condition-case nil
      (if (< (car (cdr (cdr event))) 0)
          (scroll-other-window)
        (scroll-other-window-down))
    (error nil)))

(global-set-key [M-mouse-wheel] 'mouse-wheel-scroll-line-other-window)
(global-set-key [C-M-mouse-wheel] 'mouse-wheel-scroll-screen-other-window)

(define-abbrev global-abbrev-table "rbc" "robocopy.exe /e /r:0 /zb ")

;; From http://www.gnu.org/software/emacs/windows/faq3.html

(defun w32-restore-frame ()
  "Restore a minimized frame"
  (interactive)
  (w32-send-sys-command #xf120))

(defun w32-maximize-frame ()
  "Maximize the current frame"
  (interactive)
  (w32-send-sys-command #xf030))

(defun w32-activate-screensaver ()
  "Activate the screensaver, if defined"
  (interactive)
  (w32-send-sys-command #xf140))

(add-hook 'window-setup-hook 'w32-maximize-frame)

;; Tell xcscope.el where to find the bootstrap script

(setq cscope-indexing-script (concat (expand-file-name "~/bin/") "cscope-indexer.bat"))

;; For launching bash on a Windows box

(message ".emacs: bash")

(if (boundp 'jonw-cygwin-bash)
    (defun bash ()
      (interactive)
      (if (not (comint-check-proc "*bash*"))
          (let* ((prog jonw-cygwin-bash)
                 (name (file-name-nondirectory prog))
                 (startfile (concat (expand-file-name "~/.emacs_") name))
                 (xargs-name (intern-soft (concat "explicit-" name "-args")))
                 bash-buffer)
            (save-excursion
              (set-buffer (apply 'make-comint "bash" prog
                                 (if (file-exists-p startfile) startfile)
                                 (if (and xargs-name (boundp xargs-name))
                                     (symbol-value xargs-name)
                                   '("-il"))))
              (setq bash-buffer (current-buffer))
              (shell-mode))
            (pop-to-buffer bash-buffer))
        (pop-to-buffer "*bash*"))))

;; Hqn build environment variables

(set-if-not-bound 'jonw-cv-root "C:\\hqbin\\")

(defun jonw-set-cv-var ( cv-var cv-val )
  (if (not (getenv cv-var))
      (setenv cv-var
              (replace-regexp-in-string "\/" "\\\\"
                                        (expand-file-name (concat jonw-cv-root cv-val))))))

;; Mercurial gubbins: don't want to pick up any Cygwin binary as it
;; argues with SourceTree/TortoiseHg, apparently

(setq vc-hg-program (concat
                     (getenv "USERPROFILE")
                     "\\AppData\\Local\\Atlassian\\SourceTree\\hg_local\\hg.exe"))

;; On Windows, visible-bell flashes the icon in the task bar which is
;; just as annoying. This means we properly do nowt:

(setq ring-bell-function (lambda ()))

(jonw-set-cv-var "CV_PERL_5_005_02"     "perl/perl5_005_03/5.00503/bin/MSWin32-x86-thread/perl.exe")
(jonw-set-cv-var "CV_PERL_5_005_03"     "perl/perl5_005_03/5.00503/bin/MSWin32-x86-thread/perl.exe")
(jonw-set-cv-var "CV_SIGNTOOL_1_0"      "signtool_1_0/win_32-pentium/signtool.exe")
(jonw-set-cv-var "CV_SIGNTOOL_1_1"      "signtool_1_1/win_32-pentium/signtool.exe")
(jonw-set-cv-var "CV_SIGNTOOL_2_0"      "signtool_2_0/win_32-pentium/signtool.exe")
(jonw-set-cv-var "CV_SPLINT_3_0_1_6"    "splint_3_0_1_6/win_32-pentium/Splint.exe")
(jonw-set-cv-var "CV_SPLINT_3_1_1"      "splint_3_1_1/win_32-pentium/Splint.exe")
(jonw-set-cv-var "CV_SPLINT_3_1_2"      "splint_3_1_2/win_32-pentium/Splint.exe")
(jonw-set-cv-var "CV_ARPROXY_1_0_0"     "archiveproxy/archiveproxy.exe")

(setenv "CV_GCC_3_4_2" "c:\\mingw\\bin\\gcc.exe")
(setenv "CV_GCC_3_4_2_LIB" "c:\\mingw\\lib\\gcc\\mingw32\\3.4.2")
(setenv "CV_JDK_1_2" "c:\\jdk1.2.2")
(setenv "CV_JRE_1_2" "c:\\jdk1.2.2\\jre")
(setenv "CV_JDK_1_6_0" "c:\\Program Files\\Java\\jdk1.7.0")
(setenv "CV_JRE_1_6_0" "c:\\Program Files\\Java\\jdk1.7.0\\jre")
(setenv "CV_JDK_1_6_0_21" "c:\\Program Files\\Java\\jdk1.7.0")
(setenv "CV_JRE_1_6_0_21" "c:\\Program Files\\Java\\jdk1.7.0\\jre")
(setenv "CV_JDK_1_7_0" "c:\\Program Files\\Java\\jdk1.7.0")
(setenv "CV_JRE_1_7_0" "c:\\Program Files\\Java\\jdk1.7.0\\jre")
(setenv "CV_MSVCNT_5_0" "c:\\Program Files\\DevStudio\\VC")
(setenv "CV_MSVCNT_6_0" "c:\\Program Files\\Microsoft Visual Studio\\VC98")
(setenv "CV_MSVCNT_7_0" "c:\\Program Files\\Microsoft Visual Studio .NET 2003\\Vc7")
(setenv "CV_MSVCNT_8_0" "c:\\Program Files (x86)\\Microsoft Visual Studio 8\\VC")
(setenv "CV_MSVCNT_10_0" "c:\\Program Files (x86)\\Microsoft Visual Studio 10.0\\VC")
(setenv "CV_MSVCNT_11_0" "c:\\Program Files (x86)\\Microsoft Visual Studio 11.0\\VC")
(setenv "CV_MSVCNT_12_0" "c:\\Program Files (x86)\\Microsoft Visual Studio 12.0\\VC")
(setenv "CV_MSVCNT_14_0" "c:\\Program Files (x86)\\Microsoft Visual Studio 14.0\\VC")
(setenv "CV_MSVCNT_15_2" "c:\\Program Files (x86)\\Microsoft Visual Studio\\2017\\Professional\\VC")
(setenv "CV_MSVCNT_15_3" "c:\\Program Files (x86)\\Microsoft Visual Studio\\2017\\Professional\\VC")
(setenv "CV_QUANTIFY_2001" "c:\\Program Files\\Rational\\Quantify\\quantify.exe")
(setenv "CV_ACTIVEPERL_5_8_8" "c:\\Perl_5_8_8")
(setenv "CV_HTMLHELP_1_3" "c:\\hqbin\\htmlhelp_1_3\\win_32-pentium\\hhc.exe")

(setenv "CV_DOXYGEN_1_5_1" "c:\\Program Files\\doxygen\\bin\\doxygen.exe")
(setenv "CV_GRAPHVIZ_2" "c:\\Program Files (x86)\\Graphviz2.36\\bin")

;; The above definitions are what they "should" be, but they don't
;; work (Dynalib.pm problems loading FileUtil.dll)

(setenv "CV_PERL_5_005_02" "c:\\Perl_5_8_8\\bin\\perl.exe")
(setenv "CV_PERL_5_005_03" "c:\\Perl_5_8_8\\bin\\perl.exe")

(setenv "MSVCNT" (getenv "CV_MSVCNT_5_0"))
