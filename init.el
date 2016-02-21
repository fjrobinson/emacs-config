;;; .emacs --- A basic Emacs initialization script
;;
;;; Author: Jamie Robinson
;;
;;; Commentary:
;;
;;    This file highlights how you would go about changing various
;;    aspects of Emacs' configuation.  This configuration barely
;;    scratches the surface of what is possible in Emacs.  There are
;;    many lengthy guides online that describe how to turn Emacs into
;;    a very powerful IDE for most languages.  However, this
;;    configuration mainly focuses on enhancing the user's single file
;;    editing experience while also providing the resources for
;;    expanding to more advanced functionality and plugins.
;;
;;; Code:
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes (quote (zenburn)))
 '(custom-safe-themes
   (quote
    ("020bec1abae2397c86dc6c1f58bdc72d0b0ecf71082f315a4396c099d2a19cae" "4065089f1c0f8d2847e5b6b4bea69c720e7489528af6f3f1ed69b515a7a3afe2" "0af7ad91975cd12ef3d9fd5288df5629e004a83af344188c549be2e4553ee7ca" "624356345cab0c89cddca5acd5cdbcb5a7e948752bea30496100530169d8c39e" "bcc6775934c9adf5f3bd1f428326ce0dcd34d743a92df48c128e6438b815b44f" "a27c00821ccfd5a78b01e4f35dc056706dd9ede09a8b90c6955ae6a390eb1c1e" "c74e83f8aa4c78a121b52146eadb792c9facc5b1f02c917e3dbb454fca931223" "3c83b3676d796422704082049fc38b6966bcad960f896669dfc21a7a37a748fa" "20e359ef1818a838aff271a72f0f689f5551a27704bf1c9469a5c2657b417e6c" default)))
 '(helm-gtags-auto-update t)
 '(helm-gtags-ignore-case t)
 '(helm-gtags-path-style (quote relative))
 '(inhibit-startup-screen t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; Melpa package repository setup
;; For more info and options:
;;    https://melpa.org/#/getting-started
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))
(when (< emacs-major-version 24)
  ;; For important compatibility libraries like cl-lib
  (add-to-list 'package-archives
               '("gnu" . "http://elpa.gnu.org/packages/")))
(package-initialize)

;; Install primary plugins (if not already)
(package-install 'async)
(package-install 'hlinum)
(package-install 'flx-ido)
(package-install 'smart-mode-line)
(package-install 'magit)
(package-install 'yasnippet)
(package-install 'move-text)
(package-install 'zenburn-theme)
(package-install 'rainbow-delimiters)
(package-install 'rainbow-mode)

(package-install 'irony)
(package-install 'irony-eldoc)
(package-install 'company)
(package-install 'company-flx)
(package-install 'company-irony)
(package-install 'flycheck)
(package-install 'flycheck-irony)
(package-install 'projectile)
(package-install 'helm)
(package-install 'helm-core)
(package-install 'helm-company)
(package-install 'helm-flx)
(package-install 'helm-flycheck)
(package-install 'helm-gtags)
(package-install 'helm-projectile)

;; async? DO I NEED THIS??? check this later.
(dired-async-mode 1)

;; Setup the theme
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/")
(load-theme 'zenburn 1)
(set-face-background 'vertical-border "color-234")
(set-face-foreground 'vertical-border "color-234")

;; Move lines and regions
(require 'move-text)
(move-text-default-bindings)
(global-set-key (kbd "M-n") 'move-text-down)
(global-set-key (kbd "M-p") 'move-text-up)

;; Set the fill column
(setq fill-column 80)

;; Remove menu bar
(if (eq window-system nil)
    (menu-bar-mode -1)
  '())

;; save place in files
(require 'saveplace)
(setq save-place-file "~/.emacs.d/saved-places")
(setq-default save-place t)

(defun enable-flx-ido ()
  "Enable flx-ido completion."
  (require 'flx-ido)
    (ido-mode 1)
    (ido-everywhere 1)
    (flx-ido-mode 1)
    (defvar ido-use-faces)
    (defvar ido-enable-flex-matching)
    ;; disable ido faces to see flx highlights.
    (setq ido-enable-flex-matching t)
    (setq ido-use-faces nil))

(defun enable-smart-mode-line ()
  "Enable smart-mode-line themes and features."
  (defvar sml/theme)
  ;; smart-mode-line configuration
  ;;(setq sml/theme 'dark)
  ;;(setq sml/theme 'light)
  (setq sml/theme 'respectful)
  (sml/setup))

(defun enable-auto-fill ()
  "Setup 'auto-fill-mode' and the fill column."
  (setq-default auto-fill-function
                'do-auto-fill) ; Turn auto-fill-mode on by default
  (global-set-key (kbd "C-c C-q")
                  'auto-fill-mode)) ; Toggle auto-fill-mode with the
                                    ; keyboard shortcut C-c C-q

(defun comment-auto-fill ()
  "Auto fill comments only.  Call this in programming mode hooks."
  (setq-local comment-auto-fill-only-comments t)
  (auto-fill-mode 1))

;; Show line number on each line
;; NOTE: In TTY Emacs, the numbers will count towards the line length
;;   when fill mode is in use or fill-paragraph is executed (M-q)
;; For more info and options:
;;    http://www.emacswiki.org/emacs/LineNumbers
(defun enable-line-numbers ()
  "A wrapper function to setup line numbering."
  (require 'hlinum)
  (hlinum-activate)
  (add-hook 'find-file-hook (lambda () (linum-mode 1)))
  (defvar linum-format)
  (if (eq window-system nil)
      (setq linum-format "%3d ") ; In TTY Emacs add an extra space
                                 ; after the number
    (setq linum-format "%3d"))) ; In Windowed mode just add the number
                                ; without a space since windowed mode
                                ; already has a divider with linum.

;; Indentation
;; For more info and options:
;;    http://www.emacswiki.org/emacs/IndentationBasics
;;    http://www.emacswiki.org/emacs/AutoIndentation
;;    http://www.emacswiki.org/emacs/NoTabs
(defun enable-indentation-policy ()
  "Setup indentation."
  (define-key global-map (kbd "RET")
    'newline-and-indent) ; Automatically indent on RET key pressed
                         ; NOTE: This is normally bound to C-j
  (setq-default indent-tabs-mode nil) ; substitute tabs with spaces
  )

;; Enable the semantic package.
;; For more info and options:
;;    https://www.gnu.org/software/emacs/manual/html_node/semantic/Using-Semantic.html
(defun enable-semantic ()
  "Setup semantic features."
  (require 'semantic)

  ;; Enable some basic included IDE-like features

  ;; Parse buffers while Emacs is idle
  (global-semantic-idle-scheduler-mode 1)

  ;; Store syntax parse in external database to reduce the overhead of
  ;; opening files
  (global-semanticdb-minor-mode 1)

  ;; Displays function prototype in the mini-buffer (like el-doc)
  ;;(global-semantic-idle-summary-mode 1)

  ;; Provides simple completion interface (<TAB> to cycle)
  ;;(global-semantic-idle-completions-mode 1)

  ;; Highlight the function name currently being edited
  (global-semantic-highlight-func-mode 1)

  ;; Adds some markings that you may like
  ;;(global-semantic-decoration-mode 1)

  ;; Keeps the function on the top line of the editor
  (global-semantic-stickyfunc-mode 1)

  ;; Enable semantic mode
  (semantic-mode 1))

(defun enable-helm-gtags ()
  "Setup helm gtags."
  ;;; Enable helm-gtags-mode
  ;; customize
  (custom-set-variables
   '(helm-gtags-path-style 'relative)
   '(helm-gtags-ignore-case t)
   '(helm-gtags-auto-update t))

  (defvar helm-gtags-mode-map)
  ;; key bindings
  (eval-after-load "helm-gtags"
    '(progn
       (define-key helm-gtags-mode-map (kbd "M-.") 'helm-gtags-find-tag)
       (define-key helm-gtags-mode-map (kbd "M-r") 'helm-gtags-find-rtag)
       (define-key helm-gtags-mode-map (kbd "M-s") 'helm-gtags-find-symbol)
       (define-key helm-gtags-mode-map (kbd "M-g M-p") 'helm-gtags-parse-file)
       (define-key helm-gtags-mode-map (kbd "C-c <") 'helm-gtags-previous-history)
       (define-key helm-gtags-mode-map (kbd "C-c >") 'helm-gtags-next-history)
       (define-key helm-gtags-mode-map (kbd "M-,") 'helm-gtags-pop-stack)))

  (eval-after-load 'helm (helm-gtags-mode 1)))

(defun enable-helm ()
  "Setup helm features."
  (require 'helm)
  (require 'helm-config)

  (defvar helm-map)
  (defvar helm-command-map)
  (defvar helm-google-suggest-use-curl-p)
  (defvar helm-split-window-in-side-p)
  (defvar helm-move-to-line-cycle-in-source)
  (defvar helm-ff-search-library-in-sexp)
  (defvar helm-scroll-amount)
  (defvar helm-ff-file-name-history-use-recentf)
  (defvar helm-fuzzy-match)
  (defvar helm-M-x-fuzzy-match)
  (defvar helm-buffers-fuzzy-matching)
  (defvar helm-recentf-fuzzy-match)

  (setq helm-fuzzy-match            t
        helm-M-x-fuzzy-match        t
        helm-buffers-fuzzy-matching t
        helm-recentf-fuzzy-match    t)

  ;; Helm-command-map
  (define-key helm-command-map (kbd "g")   'helm-apt)
  (define-key helm-command-map (kbd "w")   'helm-psession)
  (define-key helm-command-map (kbd "z")   'helm-complex-command-history)
  (define-key helm-command-map (kbd "w")   'helm-w3m-bookmarks)
  (define-key helm-command-map (kbd "x")   'helm-firefox-bookmarks)
  (define-key helm-command-map (kbd "#")   'helm-emms)
  (define-key helm-command-map (kbd "I")   'helm-imenu-in-all-buffers)

  ;; Global-map
  (global-set-key (kbd "C-x b")                        'helm-mini)
  (global-set-key (kbd "M-x")                          'undefined)
  (global-set-key (kbd "M-x")                          'helm-M-x)
  (global-set-key (kbd "M-y")                          'helm-show-kill-ring)
  (global-set-key (kbd "C-c f")                        'helm-recentf)
  (global-set-key (kbd "C-x C-f")                      'helm-find-files)
  (global-set-key (kbd "C-c <SPC>")                    'helm-all-mark-rings)
  (global-set-key (kbd "C-x r b")                      'helm-filtered-bookmarks)
  (global-set-key (kbd "C-h r")                        'helm-info-emacs)
  (global-set-key (kbd "C-:")                          'helm-eval-expression-with-eldoc)
  (global-set-key (kbd "C-,")                          'helm-calcul-expression)
  (global-set-key (kbd "C-h i")                        'helm-info-at-point)
  (global-set-key (kbd "C-x C-d")                      'helm-browse-project)
  (global-set-key (kbd "<f1>")                         'helm-resume)
  (global-set-key (kbd "C-h C-f")                      'helm-apropos)
  (global-set-key (kbd "C-h a")                        'helm-apropos)
  (global-set-key (kbd "<f5> s")                       'helm-find)
  (global-set-key (kbd "<f2>")                         'helm-execute-kmacro)
  (global-set-key (kbd "C-c i")                        'helm-imenu-in-all-buffers)
  ;;(global-set-key (kbd "<f11> o")                      'helm-org-agenda-files-headings)
  (global-set-key (kbd "C-s")                          'helm-occur)
  (define-key global-map [remap jump-to-register]      'helm-register)
  (define-key global-map [remap list-buffers]          'helm-buffers-list)
  (define-key global-map [remap dabbrev-expand]        'helm-dabbrev)
  (define-key global-map [remap find-tag]              'helm-etags-select)
  (define-key global-map [remap xref-find-definitions] 'helm-etags-select)
  (define-key global-map (kbd "M-g a")                 'helm-do-grep-ag)
  (define-key global-map (kbd "M-g g")                 'helm-grep-do-git-grep)
  (define-key global-map (kbd "M-g i")                 'helm-gid)

  ;; The default "C-x c" is quite close to "C-x C-c", which quits Emacs.
  ;; Changed to "C-c h". Note: We must set "C-c h" globally, because we
  ;; cannot change `helm-command-prefix-key' once `helm-config' is loaded.
  (global-set-key (kbd "C-c h") 'helm-command-prefix)
  (global-unset-key (kbd "C-x c"))

  (define-key helm-map (kbd "<tab>") 'helm-execute-persistent-action) ; rebind tab to run persistent action
  (define-key helm-map (kbd "C-i") 'helm-execute-persistent-action) ; make TAB works in terminal
  (define-key helm-map (kbd "C-z")  'helm-select-action) ; list actions using C-z

  (when (executable-find "curl")
    (setq helm-google-suggest-use-curl-p t))

  (setq helm-split-window-in-side-p           t ; open helm buffer inside current window, not occupy whole other window
        helm-move-to-line-cycle-in-source     t ; move to end or beginning of source when reaching top or bottom of source.
        helm-ff-search-library-in-sexp        t ; search for library in `require' and `declare-function' sexp.
        helm-scroll-amount                    8 ; scroll 8 lines other window using M-<next>/M-<prior>
        helm-ff-file-name-history-use-recentf t)

  (helm-autoresize-mode 1)

  (helm-mode 1)

  ;;(eval-after-load 'company '(lambda () (helm-company)))
  ;; Enable flx score based searching
  (helm-flx-mode +1))

(defun enable-flycheck ()
  "Setup Flycheck for use."

  (require 'flycheck)
  (global-flycheck-mode)

  (require 'helm-flycheck) ;; Not necessary if using ELPA package
  (defvar flycheck-mode-map)
  (eval-after-load 'flycheck
    '(define-key flycheck-mode-map (kbd "C-c C-x C-c") 'helm-flycheck)))

(defun enable-company ()
  "Setup Company for use."
  (require 'company)

  (with-eval-after-load 'company (company-flx-mode +1))
  (eval-after-load 'irony '(add-to-list 'company-backends '(company-irony company-irony-c-headers company-yasnippet)))

  (company-quickhelp-mode 1)
  ;;(setq company-quickhelp-idle-delay 0.5)
  (global-company-mode))

(defun enable-projectile ()
  "Setup projectile for project management."
  (defvar projectile-completion-system)
  (projectile-global-mode)
  (setq projectile-completion-system 'helm)
  (helm-projectile-on))

(defun enable-delight ()
  (require 'delight)
  (delight '((abbrev-mode nil "abbrev")
             (company-mode " Com" company)
             (helm-gtags-mode nil helm-gtags)
             (eldoc-mode nil eldoc)
             (helm-mode nil helm)
             (irony-mode " Fe" irony)
             (projectile-mode " Proj" projectile)
             (auto-fill-mode "AF" nil))))

(defun enable-irony ()
  "Setup c-mode functionality."
  (defvar company-backends)
  (require 'irony)
  ;;(add-hook 'irony-mode-hook 'irony-eldoc)
  (irony-mode 1)
  (irony-eldoc 1)
  (irony-cdb-autosetup-compile-options)
  (eval-after-load 'flycheck (flycheck-irony-setup)))
  ;;(eval-after-load 'company '(add-to-list 'company-backends '('company-irony 'company-irony-c-headers))))

(defun enable-yasnippet ()
  ;; yasnippet
  (require 'yasnippet)
  (yas-global-mode 1))

;; CALL THE ABOVE DEFINED FUNCTIONS TO SETUP EMACS
(enable-delight)
(enable-smart-mode-line)
(enable-line-numbers)
(enable-flx-ido)
(enable-indentation-policy)
(enable-helm)
(enable-helm-gtags)
(enable-semantic)
(enable-yasnippet)
(define-key global-map (kbd "C-c C-f") 'find-grep)

;; Fundemental mode redefine as org-mode.
(setq-default major-mode 'org-mode)

;; General programming mode enables
(add-hook 'prog-mode-hook
          (lambda ()
            (eldoc-mode)
            (rainbow-delimiters-mode)
            (comment-auto-fill)
            (enable-line-numbers)
            (enable-helm-gtags)))

;; Emacs-Lisp specific functionality.
(add-hook 'emacs-lisp-mode-hook
          (lambda ()
            ))

;; C specific functionality c-mode-hook
(add-hook 'c-mode-hook
          (lambda ()
            (enable-irony)
            ;; add more commands here
            ))

;; C++ specific functionality c++-mode-hook
(add-hook 'c++-mode-hook
          (lambda ()
            (enable-irony)
            ;; add more commands here
            ))
;;(enable-flyspell)
(enable-projectile)
(enable-flycheck)
(enable-company)

;; Give visual indication (1) or disable (2) terminal bell
;;(setq visible-bell 1)           ; (1)
(setq ring-bell-function 'ignore) ; (2)

;; Show column number in status bar
(setq column-number-mode t)

;; Remove trailing white space on save
(add-hook 'before-save-hook 'whitespace-cleanup)


(message "Buffer Size: %d" (buffer-size))

(provide '.emacs)
;;; .emacs ends here
