;;  -*- lexical-binding: t -*-
;;
;; Copyright (c) 2016 David Christiansen.
;; Released under Apache 2.0 license as described in the file LICENSE.
;;
;; Author: David Christiansen
;;
;;; Code:

(require 's)

(defface lean-message-boxes-caption-face
  '((t :inherit bold))
  "Face for Lean message box captions."
  :group 'lean)

(defcustom lean-message-boxes-enabled-captions '("check result" "print result")
  "Which captions should result in boxes?"
  :group 'lean
  :type '(repeat (choice (const "check result")
                         (const "print result")
                         (const "trace output"))))

(defvar lean-message-boxes-enabledp nil
  "Whether or not to display message boxes.")
(make-variable-buffer-local 'lean-message-boxes-enabledp)

(defun lean-message-boxes-toggle ()
  "Toggle the display of message boxes."
  (interactive)
  (setq lean-message-boxes-enabledp (not lean-message-boxes-enabledp)))

(defun lean-message-boxes-enable ()
  "Enable the display of message boxes."
  (interactive)
  (setq lean-message-boxes-enabledp t))

(defun lean-message-boxes-disable ()
  "Disable the display of message boxes."
  (interactive)
  (setq lean-message-boxes-disabledp t))

(defvar lean-message-boxes--overlays '()
  "The overlays in the current buffer from Lean messages.")
(make-variable-buffer-local 'lean-message-boxes--overlays)

(defun lean-message-boxes--kill-overlays ()
  "Delete all Lean message overlays in the current buffer."
  (dolist (o lean-message-boxes--overlays)
    (delete-overlay o))
  (setq lean-message-boxes--overlays '()))

(defun lean-message-boxes--pad-to (str width)
  "Pad the string STR to a particular WIDTH."
  (concat str (make-string (max 0 (- width (length str))) ?\ )))

(defun lean-message-boxes-display (msgs)
  "Show the messages MSGS in the Lean buffer as boxes when `lean-message-boxes-enabledp' is non-nil."
  (lean-message-boxes--kill-overlays)
  (when lean-message-boxes-enabledp
    (dolist (msg msgs)
      (let ((line (plist-get msg :pos_line))
            (col (plist-get msg :pos_col))
            (caption (plist-get msg :caption))
            (text (plist-get msg :text)))
        (when (member caption lean-message-boxes-enabled-captions)
          (let ((overlay (lean-message-boxes--make-overlay line col caption text)))
            (push overlay lean-message-boxes--overlays)))))))

(defun lean-message-boxes--as-string (caption str)
  "Construct a propertized string representing CAPTION and STR."
  (let* ((caption-copy (concat caption))
         (lines (s-lines str))
         (w (apply #'max (mapcar #'length (cons caption lines))))
         (top (concat "╭" (make-string (+ w 2) ?─) "╮"))
         (horiz (concat "├" (make-string (+ w 2) ?─) "┤"))
         (bot (concat "╰" (make-string (+ w 2) ?─) "╯")))
    (put-text-property 0 (length caption-copy)
                       'face 'lean-message-boxes-caption-face
                       caption-copy)
    (apply #'concat
           top "\n"
           "│ " (lean-message-boxes--pad-to caption-copy w)  " │\n"
           horiz "\n"
           (append
            (mapcar
             (lambda (l)
               (concat "│ "
                       (lean-message-boxes--pad-to l w)
                       " │\n"))
             lines)
            (list bot)))))

(defun lean-message-boxes--make-overlay (line col caption text)
  "Construct a message box overlay at LINE and COL with CAPTION and TEXT."
  (let* ((where (save-excursion (goto-char (point-min))
                                (forward-line (1- line))
                                (line-end-position)))
         (overlay (make-overlay where (+ 1 where))))
    (overlay-put overlay 'display
                 (concat "\n" (lean-message-boxes--as-string caption text) "\n"))
                                        ;(overlay-put overlay 'face font-lock-builtin-face)
    (overlay-put overlay 'mouse-face font-lock-warning-face)
    (overlay-put overlay 'lean-is-output-overlay t)
    overlay))

(add-hook 'lean-server-show-message-hook 'lean-message-boxes-display)
(provide 'lean-message-boxes)
