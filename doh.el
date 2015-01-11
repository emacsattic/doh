;;; doh.el --- D'oh!

;; Author: Noah Friedman <friedman@splode.com>
;; Created: 1996-06-24
;; Keywords: games
;; License: public domain

;; $Id: doh.el,v 1.4 2013/08/03 17:22:02 friedman Exp $

(require 'advice)

(defvar doh-file-name "~/etc/audio/simpsons/doh.au"
  "File name containing audio data.
This data is read into memory, but if you change the value of this
variable, the data is re-read.")

(defvar doh-device "/dev/audio"
  "Name of audio device.")

(defvar doh-hook '(doh!))

;; Don't change these.
(defvar doh-data nil)
(defvar doh-data-file-name "")

(defun doh! ()
  (interactive)
  (or (string= doh-file-name doh-data-file-name)
      (doh-initialize doh-file-name))
  ;; This makes use of a kludgy hack in Emacs 19's write-region to use a
  ;; string as the data instead an actual buffer region.
  (doh-write-region doh-data nil doh-device nil 'quiet))

(defun doh-write-region (&rest args)
  ;; Avoid mule braindamage
  (let ((coding-system-for-write 'raw-text))
    (apply 'write-region args)))

(defun doh-initialize (file-name)
  (interactive)
  (let ((buf (generate-new-buffer " *doh!*")))
    (save-excursion
      (set-buffer buf)
      (and (fboundp 'set-buffer-multibyte)
           (set-buffer-multibyte nil))
      (insert-file-contents file-name)
      (setq doh-data (buffer-substring (point-min) (point-max))))
    (kill-buffer buf))
  (setq doh-data-file-name file-name))

(defadvice ding (before run-doh-hook activate)
  "Doh!"
  (run-hooks 'doh-hook))

(defadvice keyboard-quit (around run-doh-hook activate)
  "Doh!"
  (unwind-protect
      ad-do-it
    (run-hooks 'doh-hook)))

(provide 'doh)

;;; doh.el ends here
