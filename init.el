;;; init.el --- emacs initialize file.

;;; Commentary:

;; Author: n9d
;; URL: https://github.com/n9d/emacs.init
;; Version: 0.01
;; Package-Requires: helm

;; ライセンス

;;; Code:

;;; proxy for url.el
;;(setq url-proxy-services
;;      '(("http" . "172.16.220.102:3128")
;;        ("https" . "172.16.220.102:3128")))

;; オリジナルの .elを持ってきたいときには以下を入れる
;;(setq load-path (cons (expand-file-name "~/.emacs.d/site-lisp/") load-path))


;;; package.el
;;; http://qiita.com/tadsan/items/6c658cc471be61cbc8f6 を参考にするといい
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
;;(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/") t); httpsで通らないときこちら
(package-initialize)

;; 自動でpackageをロードする関数
;; https://qiita.com/regashia/items/057b682dd29fbbdadd52
;; https://github.com/purcell/emacs.d/blob/master/lisp/init-elpa.el#L35-L61

(defun require-package (package &optional min-version no-refresh)
  "Install given PACKAGE, optionally requiring MIN-VERSION.
If NO-REFRESH is non-nil, the available package lists will not be
re-downloaded in order to locate PACKAGE."
  (if (package-installed-p package min-version)
      (require package) ;; tからこれに変えた 元のはpackageが入ってたら何もしなかったがrequireするようにした
    (if (or (assoc package package-archive-contents) no-refresh)
      (if (boundp 'package-selected-packages)
        ;; Record this as a package the user installed explicitly
        (package-install package nil)
        (package-install package))
      (progn
        (package-refresh-contents)
        (require-package package min-version t)))))

(defun maybe-require-package (package &optional min-version no-refresh)
  "Try to install PACKAGE, and return non-nil if successful.
In the event of failure, return nil and print a warning message.
Optionally require MIN-VERSION.  If NO-REFRESH is non-nil, the
available package lists will not be re-downloaded in order to
locate PACKAGE."
  (condition-case err
    (require-package package min-version no-refresh)
    (error
      (message "Couldn't install optional package `%s': %S" package err)
      nil)))


;;; テーマ
(load-theme 'deeper-blue t)

;;; helm
;;(unless (require 'helm nil t) (progn (package-refresh-contents) (package-install 'helm))) ;; helmは最初なのでここだけパッケージ一覧を更新している
(when (maybe-require-package 'helm)
  (helm-mode 1) ;helmを常に有効
  ;;(define-key helm-find-files-map (kbd "TAB") 'helm-execute-persistent-action) ;;tabはアクション選択
  (define-key global-map (kbd "M-x") 'helm-M-x) ;;M-xの検索をhelmで行う
  (define-key global-map (kbd "C-x r b") #'helm-filtered-bookmarks)
  (define-key global-map (kbd "C-x C-f") #'helm-find-files) ;;elscreen-find-fileで置き換え予定
  (define-key global-map (kbd "C-x b") 'helm-mini)
  (define-key global-map (kbd "C-x C-b") 'helm-buffers-list)
  (define-key global-map (kbd "M-y") 'helm-show-kill-ring)
  (defvar my-helm-map (make-sparse-keymap) "My original helm keymap binding F7 and C-;.")
  (defalias 'my-helm-prefix my-helm-map)
  (define-key global-map [f7] 'my-helm-prefix)
  (define-key global-map (kbd "C-;") 'my-helm-prefix) ;; ネイティブwindowの時にしかキーが取れない rloginでは C-;を"\030@c;"に割り当てる
  (define-key my-helm-map (kbd "h") 'helm-mini)
  (define-key my-helm-map (kbd "b") 'helm-mini)
  ;;(define-key my-helm-map (kbd "r") 'helm-recentf) ;; ielmの起動にした(repl)
  (define-key my-helm-map (kbd "i") 'helm-imenu)
  (define-key my-helm-map (kbd "k") 'helm-show-kill-ring)
  (define-key my-helm-map (kbd "o") 'helm-occur)
  (define-key my-helm-map (kbd "x") 'helm-M-x)
  (define-key my-helm-map (kbd "f") 'helm-browse-project) ;; git内に関係するファイル全部を絞り込める

  ;; helm-find-filesで "." ".." を削除する
  ;; https://qiita.com/ponpoko1968/items/1d2378fd3f9ed3928978
  (advice-add 'helm-ff-filter-candidate-one-by-one
              :around (lambda (fcn file)
                        (unless (string-match "\\(?:/\\|\\`\\)\\.\\{1,2\\}\\'" file)
                          (funcall fcn file))))
  )

;;; helm-descbinds C-h bの結果を絞りこめる
;;(unless (require 'helm-descbinds nil t) (package-install 'helm-descbinds))
(when (maybe-require-package 'helm-descbinds)
  (helm-descbinds-mode))


;; which-key(キーメニュー helm-descbindsと機能ダブってるよな・・・
(when (maybe-require-package 'which-key)
  (which-key-mode))


;; popwin
;; これ入れるなら rubyeのところのコード削除したほうがいい inf-rubyをpopwinに登録すれば終了？
(when (maybe-require-package 'popwin)
  ;;(require 'popwin) ;; popwinは自動ロードしない
  (setq display-buffer-function 'popwin:display-buffer)
  (setq popwin:popup-window-position 'bottom) ;; 下から
  (setq popwin:popup-window-height 0.3) ;;高さは３割

  (push '("^\*helm .+\*$"  :regexp t :height 0.4)   popwin:special-display-config)
  (push '("^\magit.+\$" :regexp t) popwin:special-display-config)
  (push '("^\*magit.+\$" :regexp t) popwin:special-display-config)
  ;;(push '("*undo-tree*") popwin:special-display-config) ;; うまく動かないもともとC-gでundotreeがうごいているのでいいか
  (push '("^\*Org-Babel.*\$" :regexp t) popwin:special-display-config))


;; multiple-cursor
(when (maybe-require-package 'multiple-cursors)
  (global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines)
  (global-set-key (kbd "C->") 'mc/mark-next-like-this)
  (global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
  (global-set-key (kbd "C-c C-<") 'mc/mark-all-like-this))


;;; silver-seacher(ag)
;;; agが入っていればhelm-agを使う
;;; 起点ディレクトリを変えたいときにはC-uC-xg
;;; sudo apt-get install silver-searcher
(when (and (executable-find "ag") (maybe-require-package 'helm-ag))
    (define-key global-map (kbd "C-x g") 'helm-ag)
    (define-key my-helm-map (kbd "g") 'helm-ag))


;;; gnu global (gtags)
;;; gnu global がインストールされているならばhelm-gtagsを使う
(when (and (executable-find "global") (maybe-require-package 'helm-gtags))
    (add-hook 'go-mode-hook (lambda () (helm-gtags-mode)))
    (add-hook 'python-mode-hook (lambda () (helm-gtags-mode)))
    (add-hook 'ruby-mode-hook (lambda () (helm-gtags-mode)))
    (add-hook 'c-mode-hook 'helm-gtags-mode)
    (setq helm-gtags-path-style 'root)
    (setq helm-gtags-auto-update t)
    ;; key bind あまり好きじゃないな C-:系に後で変える
    (add-hook 'helm-gtags-mode-hook
              '(lambda ()
                 (local-set-key (kbd "M-g") 'helm-gtags-dwim)
                 (local-set-key (kbd "M-s") 'helm-gtags-show-stack)
                 (local-set-key (kbd "M-p") 'helm-gtags-previous-history)
                 (local-set-key (kbd "M-n") 'helm-gtags-next-history)
                 (local-set-key (kbd "M-l") 'helm-gtags-select)
                 ;;入力されたタグの定義元へジャンプ
                 ;;(local-set-key (kbd "M-t") 'helm-gtags-find-tag)
                 ;;入力タグを参照する場所へジャンプ
                 ;;(local-set-key (kbd "M-r") 'helm-gtags-find-rtag)
                 )))

;;https://www.emacswiki.org/emacs/HelmSwoop
;; helmSwoopを入れる

;;; company-mode
;;; http://qiita.com/sune2/items/b73037f9e85962f5afb7
;;; http://qiita.com/syohex/items/8d21d7422f14e9b53b17
(when (maybe-require-package 'company)
  (global-company-mode) ; 全バッファで有効にする
  (setq company-idle-delay 0) ; デフォルトは0.5
  (setq company-minimum-prefix-length 2) ; デフォルトは4
  (setq company-selection-wrap-around t) ; 候補の一番下でさらに下に行こうとすると一番上に戻る
  (setq completion-ignore-case t)
  (setq company-dabbrev-downcase nil)

  (define-key company-active-map (kbd "M-n") nil)
  (define-key company-active-map (kbd "M-p") nil)
  (define-key company-active-map (kbd "C-n") 'company-select-next)
  (define-key company-active-map (kbd "C-p") 'company-select-previous)
  (define-key company-active-map (kbd "C-h") nil)
  (global-set-key (kbd "C-M-i") 'company-complete)
  (define-key company-active-map (kbd "C-M-h") 'company-show-doc-buffer) ;; ドキュメント表示はC-Shift-h
  (define-key company-active-map [backtab] 'company-select-previous) ; おまけ

  ;;色（デフォルトはどぎつい)
  (set-face-attribute 'company-preview-common nil :inherit 'company-preview :foreground "lightgrey")
  (set-face-attribute 'company-scrollbar-bg nil :background "gray")
  (set-face-attribute 'company-scrollbar-fg nil :background "steelblue")
  (set-face-attribute 'company-tooltip nil :background "lightgrey" :foreground "black")
  (set-face-attribute 'company-tooltip-selection  nil :background "light steel blue")
  )

;; pos-tip
(when (and window-system (maybe-require-package 'pos-tip)))

;; company-quickhelp
;; 登録できてるが動いていない pos-tipを使うらしい
(when (and window-system (maybe-require-package 'company-quickhelp))
    (company-quickhelp-mode +1))
  (eval-after-load 'company
    '(define-key company-active-map (kbd "C-c h") #'company-quickhelp-manual-begin))


;;; yasnippet
;; 原則メニューを見れば片付く
;; http://vdeep.net/emacs-yasnippet をみてもう少しいじる
(when (and (maybe-require-package 'yasnippet) (maybe-require-package 'yasnippet-snippets))
    (yas-global-mode 1)
    (unless (file-exists-p (expand-file-name "~/.emacs.d/mySnippets")) (make-directory (expand-file-name "~/.emacs.d/mySnippets")))
    (add-to-list 'yas-snippet-dirs (expand-file-name "~/.emacs.d/mySnippets/"))
    ;; Add yasnippet support for all company backends
    ;; https://github.com/syl20bnr/spacemacs/pull/179
    (defvar company-mode/enable-yas t
      "Enable yasnippet for all backends.")
    (defun company-mode/backend-with-yas (backend)
      (if (or (not company-mode/enable-yas) (and (listp backend) (member 'company-yasnippet backend)))
          backend
        (append (if (consp backend) backend (list backend))
                '(:with company-yasnippet))))
    (setq company-backends (mapcar #'company-mode/backend-with-yas company-backends)))


;;; elscreen  emacs版screen キーバインドが気に入らない
;;; elscreen のリナンバーは https://github.com/momomo5717/elscreen-outof-limit-mode
;;; タブをフレームタイトルに入れる https://qiita.com/kaz-yos/items/9dffd94694adf59449b7
;;(unless (require 'elscreen nil t) (package-install 'elscreen))
(when (maybe-require-package 'elscreen)
  (elscreen-start)
  (define-key elscreen-map (kbd "C-z") 'elscreen-toggle) ; C-zC-zを一つ前のwindowにする
  (define-key my-helm-map (kbd "C-;") 'elscreen-toggle) ; C-;C-;を一つ前のwindowにする
  (define-key my-helm-map (kbd "c") 'elscreen-create)
  (define-key my-helm-map (kbd "C-p") 'elscreen-previous)
  (define-key my-helm-map (kbd "C-n") 'elscreen-next)
  (define-key my-helm-map (kbd "<up>") 'elscreen-previous)
  (define-key my-helm-map (kbd "<left>") 'elscreen-previous)
  (define-key my-helm-map (kbd "<down>") 'elscreen-next)
  (define-key my-helm-map (kbd "<right>") 'elscreen-next)
  (dolist (x '(0 1 2 3 4 5 6 7 8 9)) (define-key my-helm-map (kbd (number-to-string x)) 'elscreen-jump)) ; C-;0-9をelscreen切り替え
  ;;(setq elscreen-tab-display-kill-screen nil) ;タブの先頭に[x]を表示しない
  ;;(setq elscreen-tab-display-control nil) ; header-lineの先頭に[<->]を表示しない
  ;;(define-key global-map (kbd "C-x C-f") 'elscreen-find-file)
;;; ↑ <tab>のアクションに 同じwindowで開くを入れる
  (define-key global-map (kbd "C-x d") 'elscreen-dired)
  ;; https://gist.github.com/momomo5717 からrenumberをもらった
  (defun elscreen-renumber ()
    "Elscreen renumber."
    (interactive)
    (cl-loop for i from 0 for s in (sort (elscreen-get-screen-list) '<) do
             (when (/= i s)
               (setf (car (assoc s (elscreen-get-conf-list 'screen-property))) i
                     (car (member s (elscreen-get-conf-list 'screen-history))) i
                     (car (assoc s (elscreen-get-screen-to-name-alist-cache))) i)))
    (elscreen-tab-update t))
  (defun elscreen-kill-and-kill-buffer ()
    "Elscreen kill and kill buffer."
    (interactive)
    (unless (string= (buffer-name) "*scratch*") (kill-buffer))
    ;;(kill-buffer)
    (elscreen-kill)
    (elscreen-renumber) ;; タブナンバーを振り付けする、ショートカットの関係上本当は1カラにしたい http://d.hatena.ne.jp/ken_m/20110607/1307451681
    )
  ;;  (if (eq 1 (length (elscreen-get-screen-list))) ;;elscreenのタブの数はこれでわかる
  (define-key global-map (kbd "C-x k") 'elscreen-kill-and-kill-buffer))


;;; helm-elscreen
;;; elscreenのインターフェイスをhelmにする
;;; またhelmのactionのデフォルトをelscreenにする
(when (and (maybe-require-package 'helm) (maybe-require-package 'elscreen) (maybe-require-package 'helm-elscreen))
  (setq helm-type-file-actions (cons '("Find file Elscreen" . helm-elscreen-find-file) helm-type-file-actions)) ;;helm-findのとき
  (setq helm-find-files-actions (cons '("Find file Elscreen" . helm-elscreen-find-file) helm-find-files-actions)) ;;helm-find-filesはこちら
  (setq helm-type-buffer-actions (cons '("Find buffer elscreen" . helm-elscreen-find-buffer) helm-type-buffer-actions)))


;;; sr-speedbar
;;; デフォルトでくっついてくるspeedbarをフレーム(window内に入れる)
;;; そのうち neotreeに変える
(when (maybe-require-package 'sr-speedbar)
  (unless (require 'sr-speedbar nil t) (package-install 'sr-speedbar))
  (setq sr-speedbar-right-side nil)
  (define-key global-map [f8] 'sr-speedbar-toggle) ;F8キーをspeedbarのon/offにする
  ;; speedbarでhelm-ag 右ボタンメニューに入れられてない。
  (defun my/speedbar-helm-ag ()
    "Execute helm ag on speedbar directory."
    (interactive)
    (helm-ag (speedbar-line-file)))
  (define-key speedbar-file-key-map "G" 'my/speedbar-helm-ag))


;;; org-mode
;;; 最新のorgmodeでditaaが動かないので ubuntu16.04付属のorgを使う
;;; 埋め込みは http://tanehp.ec-net.jp/heppoko-lab/prog/resource/org_mode/org_mode_memo.html が参考になる
;;; #+ の補完をやってくれるようにする
;;(require 'org-mode)
(add-hook 'org-mode-hook #'my-org-mode-hook)
(defun my-org-mode-hook ()
  "My org mode hook."
  (progn
    (add-hook 'completion-at-point-functions 'pcomplete-completions-at-point nil t)))

;; org-modeロード時に評価
(with-eval-after-load 'org
    ;; babel の出力の調整
    (setf (alist-get :exports org-babel-default-header-args) "both") ;; githubではbothにしておかないと表示しない
    (require 'ob-python) ;; これをやっておかないとheade-ags:pythonが見えない
    (setf (alist-get :results org-babel-default-header-args:python) "output") ;; pythonはデフォoutputのほうが使いやすい
    (require 'ob-js) ;; これをやっておかないとheade-ags:pythonが見えない
    (setf (alist-get :results org-babel-default-header-args:js) "output") ;; jsも

    ;; org template expansion に 加える githubのorg-modeが :exports bothにしないと出力しない
    (add-to-list 'org-structure-template-alist '("J" "#+BEGIN_SRC js :exports both\n?\n#+END_SRC"))
    (add-to-list 'org-structure-template-alist '("R" "#+BEGIN_SRC ruby :exports both\n?\n#+END_SRC"))
    (add-to-list 'org-structure-template-alist '("P" "#+BEGIN_SRC python :exports both\n?\n#+END_SRC"))
    (add-to-list 'org-structure-template-alist '("S" "#+BEGIN_SRC sh :exports both\n?\n#+END_SRC"))
    (add-to-list 'org-structure-template-alist '("E" "#+BEGIN_SRC emacs-lisp :exports both :results pp\n?\n#+END_SRC"))

    (define-key org-mode-map (kbd "\C-cp") 'picture-mode) ;; org-modeではC-cpで起動

    (when (eq system-type 'darwin) ;; macのときだけorgの段落キーバインドを変える
      (define-key org-mode-map (kbd "M-{") 'elscreen-previous)
      (define-key org-mode-map (kbd "M-}") 'elscreen-next))
    )

(define-key my-helm-map (kbd "a") 'org-agenda)
(define-key my-helm-map (kbd "c") 'org-capture)

;;(setq org-startup-with-inline-images t) ;;インライン画像を表示 C-cC-xC-vでトグルするので不要
;; http://lioon.net/org-mode-view-style をもう少し研究する

;;https://skalldan.wordpress.com/2011/07/16/%E8%89%B2%E3%80%85-org-capture-%E3%81%99%E3%82%8B-2/ これが参考になる？

(unless (file-exists-p (expand-file-name "~/org")) (make-directory (expand-file-name "~/org"))) ;ホームにorgがなかったら作る
(setq org-capture-templates
      '(("t" "Todo" entry (file+headline "~/org/gtd.org" "Tasks") "* TODO %?\n  %i\n  %a")
        ("j" "Journal" entry (file+datetree "~/org/journal.org") "* %?\nEntered on %U\n  %i\n  %a")))


(setq org-todo-keywords '((sequence "TODO(t)" "WAIT(w)" "|" "DONE(d)" "SOMEDAY(s)"))) ;; TODO状態
(setq org-log-done 'time);; DONEの時刻を記録

;;http://misohena.jp/blog/2017-10-26-how-to-use-code-block-of-emacs-org-mode.html
;; メモ書きに大変便利、結果は#+begin_src ruby で結果はC-cC-c出力
(org-babel-do-load-languages
 'org-babel-load-languages
 (mapcar (lambda (lang) (cons lang t))
         `(ditaa
           dot
           ;octave
           perl
           python
           ruby
           js
           shell
           ,(if (locate-library "ob-shell") 'shell 'sh)
           sqlite
           )))

;; ditaaの設定
;; #+begin_src ditaa :file images/ditaa-test.png :cmdline -s 2 日本語を通したいときには左記のヘッダにする
;; http://d.hatena.ne.jp/tamura70/20100317/org を参照のこと
;;(setq org-ditaa-jar-path (expand-file-name "~/bin/jditaa.jar")) ;; ditaaのパス
(setq org-ditaa-jar-path (expand-file-name "~/bin/ditaa0_9.jar")) ;; ditaaのパス
(setq org-confirm-babel-evaluate nil) ;; コードを評価するとき尋ねない ditaa作成時の問い合わせをoff

;;; org-mode のエクスポーター
(maybe-require-package 'htmlize) ;; htmlize orgから出力するのに必要
(maybe-require-package 'ox-qmd) ;; ox-qmd qiita用

(and window-system (maybe-require-package 'org-download)) ;; ドラッグ＆ドロップで画像をorgに貼り付ける


;;;
;;; 拡張したpictureモードC-矢印で線がかける
(add-hook 'picture-mode-hook 'picture-mode-init2)
(autoload 'picture-mode-init "picture-init")
(require 'picture)

(defun picture-mode-init2 ()
  "Use cursor keys to operate picture mode."
  (define-key picture-mode-map [C-right] 'picture-line-draw-right)
  (define-key picture-mode-map [C-left]  'picture-line-draw-left)
  (define-key picture-mode-map [C-up]    'picture-line-draw-up)
  (define-key picture-mode-map [C-down]  'picture-line-draw-down)
  (define-key picture-mode-map [A-right] 'picture-line-delete-right)
  (define-key picture-mode-map [A-left]  'picture-line-delete-left)
  (define-key picture-mode-map [A-up]    'picture-line-delete-up)
  (define-key picture-mode-map [A-down]  'picture-line-delete-down)
  (define-key picture-mode-map [M-right] 'picture-line-delete-right)
  (define-key picture-mode-map [M-left]  'picture-line-delete-left)
  (define-key picture-mode-map [M-up]    'picture-line-delete-up)
  (define-key picture-mode-map [M-down]  'picture-line-delete-down)
  (define-key picture-mode-map [(control ?c) C-right] 'picture-region-move-right)
  (define-key picture-mode-map [(control ?c) C-left]  'picture-region-move-left)
  (define-key picture-mode-map [(control ?c) C-up]    'picture-region-move-up)
  (define-key picture-mode-map [(control ?c) C-down]  'picture-region-move-down)
  nil)

(defun picture-line-draw-str (h v str) "Picture line draw str.  H V STR."
       (cond ((/= h 0) (cond ((string= str "|") "+") ((string= str "+") "+") (t "-")))
             ((/= v 0) (cond ((string= str "-") "+") ((string= str "+") "+") (t "|")))
             (t str)))

(defun picture-line-delete-str (h v str) "Picture line delete str.  H V STR."
       (cond ((/= h 0) (cond ((string= str "|") "|") ((string= str "+") "|") (t " ")))
             ((/= v 0) (cond ((string= str "-") "-") ((string= str "+") "-") (t " ")))
             (t str)))

(defun picture-line-draw (num v h del)
  "Picture line draw.  NUM V H DEL."
  (let ((indent-tabs-mode nil)
        (old-v picture-vertical-step)
        (old-h picture-horizontal-step))
    (setq picture-vertical-step v)
    (setq picture-horizontal-step h)
    ;; (setq picture-desired-column (current-column))
    (while (>= num 0)
      (when (= num 0)
        (setq picture-vertical-step 0)
        (setq picture-horizontal-step 0))
      (setq num (1- num))
      (let (str new-str)
        (setq str (if (eobp) " " (buffer-substring (point) (+ (point) 1))))
        (setq new-str (if del (picture-line-delete-str h v str) (picture-line-draw-str h v str)))
        (picture-clear-column (string-width str))
        (picture-update-desired-column nil)
        (picture-insert (string-to-char new-str) 1)))
    (setq picture-vertical-step old-v)
    (setq picture-horizontal-step old-h)))

(defun picture-region-move (start end num v h)
  "Picture line region move.  START END NUM V H."
  (let ((indent-tabs-mode nil)
        (old-v picture-vertical-step)
        (old-h picture-horizontal-step) rect)
    (setq picture-vertical-step v)
    (setq picture-horizontal-step h)
    (setq picture-desired-column (current-column))
    (setq rect (extract-rectangle start end))
    (clear-rectangle start end)
    (goto-char start)
    (picture-update-desired-column t)
    (picture-insert ?\  num)
    (picture-insert-rectangle rect nil)
    (setq picture-vertical-step old-v)
    (setq picture-horizontal-step old-h)))

(defun picture-region-move-right (start end num) "Move a rectangle right.  START END NUM." (interactive "r\np") (picture-region-move start end num 0 1))
(defun picture-region-move-left (start end num) "Move a rectangle left.  START END NUM." (interactive "r\np") (picture-region-move start end num 0 -1))
(defun picture-region-move-up (start end num) "Move a rectangle up.  START END NUM." (interactive "r\np") (picture-region-move start end num -1 0))
(defun picture-region-move-down (start end num) "Move a rectangle left.  START END NUM." (interactive "r\np") (picture-region-move start end num 1 0))
(defun picture-line-draw-right (n) "Draw line right.  N." (interactive "p") (picture-line-draw n 0 1 nil))
(defun picture-line-draw-left (n) "Draw line left.  N." (interactive "p") (picture-line-draw n 0 -1 nil))
(defun picture-line-draw-up (n) "Draw line up.  N." (interactive "p") (picture-line-draw n -1 0 nil))
(defun picture-line-draw-down (n) "Draw line down.  N." (interactive "p") (picture-line-draw n 1 0 nil))
(defun picture-line-delete-right (n) "Delete line right.  N." (interactive "p") (picture-line-draw n 0 1 t))
(defun picture-line-delete-left (n) "Delete line left.  N." (interactive "p") (picture-line-draw n 0 -1 t))
(defun picture-line-delete-up (n) "Delete line up.  N." (interactive "p") (picture-line-draw n -1 0 t))
(defun picture-line-delete-down (n) "Delete line down.  N." (interactive "p") (picture-line-draw n 1 0 t))


;; magit
;; https://qiita.com/maueki/items/70dbf62d8bd2ee348274
;; https://qiita.com/egg_chicken/items/948f8df70069334e8296
;; helm-ls-gitでもいいかも
;; projectile,helm-projectileの関係を整理する
(unless (require 'magit nil t) (package-install 'magit))
(global-set-key (kbd "C-x m") 'magit-status) ;; magitを立ち上げるとC-xgも有効になってしまう
(define-key my-helm-map (kbd "m") 'magit-status)


;; vc-annotate ファイルが巨大だとgit brameがきれいに動かない VCのC-xvgは秀逸！
;; https://blog.kyanny.me/entry/2014/08/16/022311
(defadvice vc-git-annotate-command (around vc-git-annotate-command activate)
  "Suppress relative path of file from git blame output."
  (let ((name (file-relative-name file)))
    (vc-git-command buf 'async nil "blame" "--date=iso" rev "--" name)))


;;; ediff
(setq ediff-window-setup-function 'ediff-setup-windows-plain) ;コントロール用のバッファを同一フレーム内に表示
(setq ediff-split-window-function 'split-window-horizontally) ; diffのバッファを上下ではなく 左右に並べる


;;; undo tree
;;; undoを木構造で表示できる
;;; 問題点は C-?がwindowsのC-yのredoとはちょっと違うことあくまでundoの取り消しとしてのredo
;;; 繰り返しはキーボードマクロつかえということか。（redoまわりは今後調整する)
;;; undo-tree 自身はC-xuで起動
(when (maybe-require-package 'undo-tree)
  (global-undo-tree-mode)
  (define-key global-map (kbd "M-/") 'undo-tree-redo)) ;; C-/ がundoの反対


;;; 操作系の基本設定
(setq suggest-key-bindings t)        ; キーバインドの通知(登録されているキーが有るとき教えてくれる)
(fset 'yes-or-no-p 'y-or-n-p)        ; (yes/no) を (y/n)に
(define-key global-map (kbd "C-^") 'help-command) ; terminal接続時にはC-hがBSになるのでC-^をとっておく
(setq confirm-kill-processes nil) ;終了時processが残っていても問い合わせない 25以上でないと動かない

;;; バックアップファイルを~/.emacs.d/backupへ
(unless (file-exists-p (expand-file-name "~/.emacs.d/backup")) (make-directory (expand-file-name "~/.emacs.d/backup")))
(setq backup-directory-alist (cons (cons ".*" (expand-file-name "~/.emacs.d/backup")) backup-directory-alist)) ;バックアップ
(setq auto-save-file-name-transforms `((".*", (expand-file-name "~/.emacs.d/backup/") t))) ; 自動保存ファイル


;;;カーソル位置を記憶
;;; 一度 M-x toggle-save-placeを実行しないと動かない？
(if (and (>= emacs-major-version 24) (>= emacs-minor-version 5))
    (progn (require 'saveplace) (setq-default save-place t));; For GNU Emacs 24.5 and older versions.
  (save-place-mode 1)) ;; For GNU Emacs 25.1 and newer versions.


;;; tab全角スペース可視化（赤いので普段から使わなくなる）
(global-whitespace-mode 1)
(setq whitespace-space-regexp "\\(\u3000\\)")
(setq whitespace-style '(face tabs tab-mark spaces space-mark))
(setq whitespace-display-mappings ())
(set-face-foreground 'whitespace-tab "yellow")
(set-face-underline  'whitespace-tab t)
(set-face-foreground 'whitespace-space "yellow")
(set-face-background 'whitespace-space "red")
(set-face-underline  'whitespace-space t)


;;;プログラム記述系の共通設定
;; モード毎に設定したほうが良いかも
(setq-default indent-tabs-mode nil) ;; tabは使ない
(setq-default tab-width 2) ;; インデントは2文字(pythonのルールと衝突してる)
(add-hook 'before-save-hook 'delete-trailing-whitespace) ;;行末スペースをsave時に自動削除


;;; flycheck
(when (maybe-require-package 'flycheck)
  (add-hook 'after-init-hook #'global-flycheck-mode)
  (when window-system
    (maybe-require-package 'flycheck-pos-tip));; pos-tipでエラーを表示
  )


;; C-mode
;;;https://qiita.com/sune2/items/c040171a0e377e1400f6 でc/c++の補完ができる
;; まだいいか・・・

;;; js2-mode
;; https://qiita.com/sune2/items/e54bb5db129ae73d004b
;; https://emacs.cafe/emacs/javascript/setup/2017/04/23/emacs-setup-javascript.html タグジャンプはここにある ctags不要
(unless (require 'js2-mode nil t) (package-install 'js2-mode))
(add-to-list 'auto-mode-alist '("\\.js$" . js2-mode))
(add-hook 'js2-mode-hook #'js2-imenu-extras-mode)
(add-hook 'js2-mode-hook (lambda () (set (make-local-variable 'js2-indent-switch-body) t) )) ;;jsのcase文のインデントを通常へ
;;(setq js2-basic-offset 2) ;; js2modeのインデントを２へ

;; nodejsのインストール https://qiita.com/SUZUKI_Masaya/items/fb142350975f2f8bf088
;; https://emacs.stackexchange.com/questions/17537/best-company-backends-lists/17548
;; 補完にnodejsのternを用いる
;; sudo npm install -g tern
(when (executable-find "tern")
  (unless (file-exists-p (expand-file-name "~/.tern-config")) ;.tern-configがなかったら作る
    (with-temp-buffer
      (insert "{\n    \"libs\": [\n        \"browser\",\n        \"jquery\"\n    ],\n    \"loadEagerly\": [\n        \"importantfile.js\"\n    ],\n    \"plugins\": {\n        \"requirejs\": {\n            \"baseURL\": \"./\",\n            \"paths\": {}\n        }\n    }\n}\n")
      (write-file (expand-file-name "~/.tern-config"))))

  (unless (require 'company-tern nil t) (package-install 'company-tern))
  (setq company-tern-property-marker "")
  (defun company-tern-depth (candidate)
    "Return depth attribute for CANDIDATE. 'nil' entries are treated as 0."
    (let ((depth (get-text-property 0 'depth candidate)))
      (if (eq depth nil) 0 depth)))
  ;;(add-hook 'js2-mode-hook 'tern-mode) ; 自分が使っているjs用メジャーモードに変える
  ;;company-backendsの切り替え
  (dolist (hook '(js-mode-hook
                  js2-mode-hook
                  ;;js3-mode-hook
                  ;;inferior-js-mode-hook
                  ))
    (add-hook hook
              (lambda ()
                (tern-mode t)
                ;;(add-to-list (make-local-variable 'company-backends) 'company-tern) ;; ternのみが補完候補
                ;;(add-to-list (make-local-variable 'company-backends) '(company-tern :with company-dabbrev-code)) ;;バッファ上の他の単語も候補にする
                (add-to-list (make-local-variable 'company-backends) '(company-tern :with company-dabbrev-code company-yasnippet)) ;;バッファ上の他の単語も候補にする
                ;; project(git)内の関数とかも補完候補にしたい
                ))
    )
  )

;; eslintによるflycheck
;;https://joppot.info/2017/04/12/3777
;; sudo npm install -g eslint
(when (executable-find "eslint")
  (unless (file-exists-p (expand-file-name "~/.eslintrc")) ;.eslintrcがなかったら作る
    (with-temp-buffer
      (insert "{\n  \"env\" : {\n    \"es6\": true\n  },\n  \"ecmaFeatures\": {\n    \"jsx\": true\n  }\n}\n")
      (write-file (expand-file-name "~/.eslintrc"))))
  (dolist (hook '(js-mode-hook
                  js2-mode-hook
                  ;;js3-mode-hook
                  ;;inferior-js-mode-hook
                  ))
    (add-hook hook ; jshint,jscsを無効にする
              (lambda ()
                (eval-after-load 'flycheck
                  '(custom-set-variables
                    '(flycheck-disabled-checkers '(javascript-jshint javascript-jscs))))
                (setq js2-include-browser-externs nil)
                (setq js2-mode-show-parse-errors nil)
                (setq js2-mode-show-strict-warnings nil)
                (setq js2-highlight-external-variables nil)
                (setq js2-include-jslint-globals nil)
                ))
    )
  )


;;;
;;; web-mode.
;;; js,css混在のソースをいじっている時に助かる

(unless (require 'web-mode nil t) (package-install 'web-mode))
(add-to-list 'auto-mode-alist '("\\.html?$"     . web-mode)) ;;; 適用する拡張子
;; コンソールでは tag auto closeが無効になっているのでオンにする
(setq web-mode-auto-close-style 2)
(setq web-mode-enable-auto-closing t)
(setq web-mode-enable-auto-pairing t)
(setq web-mode-enable-auto-indentation t)
(setq web-mode-enable-auto-expanding t)

;;; web-modeでの補完？
(unless (require 'company-web nil t) (package-install 'company-web))
(require 'company-web-html)


;; web-modeの設定
(defun my-web-mode-hook ()
  "My web mode hook."
  (setq web-mode-markup-indent-offset 2)
  (setq web-mode-css-indent-offset 2)
  (setq web-mode-code-indent-offset 2)

  ;; 補完
  (set (make-local-variable 'company-backends)
       '(company-tern company-css company-web-html company-yasnippet company-files))

  ;; web-mode. colors.
  (set-face-attribute 'web-mode-doctype-face nil :foreground "#4A8ACA")
  (set-face-attribute 'web-mode-html-tag-face nil :foreground  "#4A8ACA")
  (set-face-attribute 'web-mode-html-attr-name-face nil :foreground  "#87CEEB")
  (set-face-attribute 'web-mode-html-attr-equal-face nil :foreground  "#FFFFFF")
  (set-face-attribute 'web-mode-html-attr-value-face nil :foreground  "#D78181")
  (set-face-attribute 'web-mode-comment-face nil :foreground  "#587F35")

  ;; web-mode. css colors.
  (set-face-attribute 'web-mode-css-at-rule-face nil :foreground "#DFCF44")
  (set-face-attribute 'web-mode-css-selector-face nil :foreground "#DFCF44")
  (set-face-attribute 'web-mode-css-pseudo-class-face nil :foreground "#DFCF44")
  (set-face-attribute 'web-mode-css-property-name-face nil :foreground "#87CEEB")
  (set-face-attribute 'web-mode-string-face nil :foreground "#D78181")

  ;;etq web-mode-engines-alist '(("php" . "\\.ctp\\'")) )
  )


;;(flycheck-add-mode 'javascript-eslint 'web-mode)

(add-hook 'web-mode-hook
          (lambda ()
            (when (or (equal web-mode-content-type "javascript")
                      (equal web-mode-content-type "jsx"))
              (flycheck-add-mode 'javascript-eslint 'web-mode)
              (flycheck-mode))))

(add-hook 'web-mode-hook 'my-web-mode-hook)

;; Enable JavaScript completion between <script>...</script> etc.
(advice-add 'company-tern :before
            #'(lambda (&rest _)
                (if (equal major-mode 'web-mode)
                    (let ((web-mode-cur-language
                           (web-mode-language-at-pos)))
                      (if (or (string= web-mode-cur-language "javascript")
                              (string= web-mode-cur-language "jsx"))
                          (progn
                            (unless tern-mode (tern-mode))
                            ;;(flycheck-add-mode 'javascript-eslint 'web-mode)
                            ;;(flycheck-mode)
                            )
                        (progn
                          (if tern-mode (tern-mode -1))
                          ))))))

;; css(<style>)の補完がいまいちな気がする
;; アイデアとしては company-cssにdefadvice してcompany-backendsを切り替える

;; (add-hook 'web-mode-hook (lambda ()
;;                            (set (make-local-variable 'company-backends) '(company-web-html))
;;                            (company-mode t)))

;; Enable CSS completion between <style>...</style>
;; (defadvice company-css (before web-mode-set-up-ac-sources activate)
;;   "Set CSS completion based on current language before running `company-css'."
;;   (if (equal major-mode 'web-mode)
;;       (let ((web-mode-cur-language (web-mode-language-at-pos)))
;;         (if (string= web-mode-cur-language "css")
;;             (unless css-mode (css-mode))))))

;; Enable JavaScript completion between <script>...</script> etc.
;; (defadvice company-tern (before web-mode-set-up-ac-sources activate)
;;   "Set `tern-mode' based on current language before running `company-tern'."
;;   (if (equal major-mode 'web-mode)
;;       (let ((web-mode-cur-language (web-mode-language-at-pos)))
;;         (if (or (string= web-mode-cur-language "javascript")
;;                 (string= web-mode-cur-language "jsx"))
;;             (unless tern-mode (tern-mode))
;;           ;; (if tern-mode (tern-mode))
;;                     ))))

;; web-mode のeslintは http://umi-uyura.hatenablog.com/entry/2015/10/28/182320 を参照すること


;;;
;;; ruby mode
;;;
;;;
;; https://qiita.com/kod314/items/9a56983f0d70f57420b1 を参考にした
;; inf-ruby irbをバッファで起動する
(when (executable-find "pry") ;; pryが必要
  (unless (require 'inf-ruby nil t) (package-install 'inf-ruby))
  (autoload 'inf-ruby-minor-mode "inf-ruby" "Run an inferior Ruby process" t)
  (add-hook 'ruby-mode-hook 'inf-ruby-minor-mode)

  ;; do endなどの補完
  ;; 通常の electricのほうが使いやすいので切る
  ;;(unless (require 'ruby-electric nil t) (package-install 'ruby-electric))
  ;;(add-hook 'ruby-mode-hook '(lambda () (ruby-electric-mode t)))
  ;;(setq ruby-electric-expand-delimiters-list nil)

  ;; 補完機能

  ;; M-x inf-ruby
  ;; M-x robe-startしないとオムニ補完しない → した
  ;; https://github.com/dgutov/robe
  ;; 懸念点 railsのフォルダ等でinf-rubyが確立していない
  (unless (require 'robe nil t) (package-install 'robe))
  (autoload 'robe-mode "robe" "Code navigation, documentation lookup and completion for Ruby" t nil)
  ;;(add-hook 'ruby-mode-hook 'robe-mode)

  (require 'cl-extra) ;; めんどくさいのでclきっと入れちゃう
  (defun myRubyMode-set-ruby-buffer-other-window ()
    (when
        (let
            ((s "*ruby*"))
          (not (cl-some (lambda (w) (string= s (buffer-name (window-buffer w)))) (window-list))))
      (delete-other-windows)
      (split-window (selected-window) (* (/ (frame-height) 3) 2))
      (select-window (next-window))
      (switch-to-buffer (get-buffer "*ruby*"))
      (select-window (next-window))
      t
      ))

  (defun myRubyMode-send-buffer () ;; 画面分割して現在のバッファを実行する
    "Send current buffer to *ruby*"
    (interactive)
    (progn
      (myRubyMode-set-ruby-buffer-other-window)
      (ruby-send-buffer-and-go) ;; *ruby*バッファに移動して 末尾に移動する（オートスクロールの方法がわからない）
      (goto-char (point-max))
      (select-window (next-window)) ;;もとに戻る
      ))


  ;; inf-ruby起動時のinf-rubyバッファをpopwinに対応させる
  (add-hook
   'ruby-mode-hook
   (lambda ()
     (let ((curbuf (current-buffer)))
       (inf-ruby)
       (dolist (window (window-list)) (if (string= "*ruby*" (buffer-name (window-buffer window))) (delete-window window))) ;; rubyバッファを消す
       (set-buffer curbuf))
     (robe-mode)
     (robe-start)
     ;;(eval-after-load 'company '(push 'company-robe company-backends))
     (add-to-list (make-local-variable 'company-backends) '(company-robe :with company-dabbrev-code company-yasnippet)) ;;バッファ上の他の単語も候補にする これちゃんと動いてるか不明

     (local-set-key [f5] 'myRubyMode-send-buffer)

     ))
  )


;;;
;;; markdown mode
;;;
;;; https://qiita.com/howking/items/bcc4e05bfb16777747fa を見て研究する
(when (executable-find "jq")
  (unless (require 'markdown-mode nil t) (package-install 'markdown-mode))
  (unless (require 'markdown-mode+ nil t) (package-install 'markdown-mode+))
  ;; markdownコマンドは github の markdown api
  (setq markdown-command "jq --slurp --raw-input '{\"text\": \"\\(.)\", \"mode\": \"gfm\"}' | curl -sS --data @- https://api.github.com/markdown")
  (autoload 'markdown-mode "markdown-mode"
   "Major mode for editing Markdown files" t)
  (add-to-list 'auto-mode-alist '("\\.markdown\\'" . markdown-mode))
  (add-to-list 'auto-mode-alist '("\\.md\\'" . gfm-mode))
  (eval-after-load "markdown-mode"
  '(defalias 'markdown-add-xhtml-header-and-footer 'my/markdown-add-html5-header-and-footer))
(defun my/markdown-add-html5-header-and-footer (title)
    "Wrap XHTML header and footer with given TITLE around current buffer."
    (goto-char (point-min))
    (insert "<!doctype html>\n"
        "<html lang=\"ja\">\n"
        "<head>\n  <title>")
    (insert title)
    (insert "</title>\n")
    (insert "  <meta charset=\"utf-8\">\n")
    (insert "  <link href=\"https://cdnjs.cloudflare.com/ajax/libs/github-markdown-css/2.8.0/github-markdown.min.css\" rel=\"stylesheet\">\n")
    (insert "  <style>body { zoom: 150%; } body > h1:not(:first-child) { border: 0; page-break-before: always; } h2{ page-break-before: always; }</style>\n")
    (insert "  <style>\n")
    (insert "  @media screen { div.footer { display: none; } }\n")
    (insert "  @media print { @page { size: legal landscape; margin-top: 0; margin-bottom: 6mm; } h1 { padding-top: 50mm; } h2 { padding-top: 0 } div.footer { position: fixed; right: 0; bottom: 0; } }\n")
    (insert "  </style>\n")
    (insert "</head>\n"
        "<body class=\"markdown-body\">\n")
    (goto-char (point-max))
    (insert "\n"
            "<div class=\"footer\"><img src=\"https://user-images.githubusercontent.com/13231263/31114194-d9656554-a857-11e7-8a87-245bf60475be.png\" style=\"width: 80px\"></div>"
            "</body>\n" "</html>\n"))
  )

;;; ielm (emacs lisp(elisp)のREPL)
;; カーソルキーの上下を履歴にする
(require 'ielm)
(define-key ielm-map (kbd "<up>") 'comint-previous-input)
(define-key ielm-map (kbd "<down>") 'comint-next-input)
(defun exec-ielm ()
  "Exec ielm."
  (interactive)
  (elscreen-create)
  (ielm)
  )
(define-key my-helm-map (kbd "r") 'exec-ielm)

;;; eshell (emacs上のshell)
;;; 履歴と補完をhelmで行う
(add-hook 'eshell-mode-hook
          #'(lambda () (define-key eshell-mode-map (kbd "M-p") 'helm-eshell-history))) ;; helm で履歴から入力
(add-hook 'eshell-mode-hook
          #'(lambda () (define-key eshell-mode-map (kbd "M-n") 'helm-esh-pcomplete))) ;; helm で補完


;;; smart-compile
;;; http://th.nao.ac.jp/MEMBER/zenitani/elisp-j.html#smart-compile
(unless (require 'smart-compile nil t) (package-install 'smart-compile))
;;;(global-set-key (kbd "C-c C-c") 'smart-compile)
;;(setq compile-command "node ")
(dolist
    (hook '(c-mode-hook js-mode-hook ruby-mode-hook python-mode-hook))  ;;smartcompileを実行するmode-hookを登録していく
    ;; ruby-modeは*ruby*バッファがいるときにはずす構成にすること（まだやってない）
    ;;(hook '(c-mode-hook js-mode-hook python-mode-hook))  ;;smartcompileを実行するmode-hookを登録していく
  (add-hook hook
            (lambda ()
              (local-set-key (kbd "C-c c") 'smart-compile)
              (local-set-key [f5] (kbd "C-x C-s C-c c C-m"))
              (local-set-key [f6] 'next-error)
              (local-set-key (kbd "C-c @") 'next-error)
              ;;(setq compilation-window-height 15)
              (setq compilation-window-height (/ (frame-height) 3)) ;; デフォルトは画面の下半分→1/3
              (setq compilation-scroll-output t) ;;コンパイル時スクロールon
              )))

;;ディレクトリごとにコンパイルコマンド変えるときここをいじる
(when (boundp 'smart-compile-alist)
  (setq smart-compile-alist
        (append smart-compile-alist
                '(("\\.c\\'" . "gcc %f")
                  ("\\.rb\\'" . "ruby %f")
                  ("\\.py\\'" . "python %f")
                  ("\\.js\\'" . "node %f")
                  )))
  (if (file-exists-p (expand-file-name "~/sptv"))  (add-to-list 'smart-compile-alist `(,(expand-file-name "~/sptv/.*") . "cd ~/sptv/sptv_base;make func")))
  )


;;; ansi-term
(defun exec-ansi-term ()
  "Swith another elscreen and exec ansi term."
  (interactive)
  (elscreen-create)
  ;;(ansi-term "/bin/bash")
  (ansi-term (locate-file "bash" exec-path exec-suffixes 1))
  )
;; (defun kill-ring-save-and-char-mode ()
;;   "Save kill ring and go to char mode."
;;   (interactive)
;;   (kill-ring-save)
;;  (term-char-mode))
;;(define-key term-mode-map (kbd "M-w") ;; M-wでchar-modeに移るようにしたい。＞そのうち
(define-key my-helm-map (kbd "t") 'exec-ansi-term)
(defun change-term-char-mode-and-elscreen-toggle ()
  "Change term line mode and elscreen toggle."
  (interactive)
  (term-char-mode)
  (elscreen-toggle))

(add-hook 'term-exec-hook
          #'(lambda ()
              (define-key term-raw-map (kbd "C-; [") 'term-line-mode)
              (define-key term-mode-map (kbd "C-; [") 'term-char-mode)
              (define-key term-mode-map (kbd "C-; C-;") 'change-term-char-mode-and-elscreen-toggle)))




;;; 以下はemacsが自動で設定したもの
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
    (powerline markdown-mode+ mozc inf-ruby helm-flycheck flycheck web-mode undo-tree sr-speedbar smart-compile rainbow-delimiters js2-mode helm-gtags helm-elscreen helm-descbinds helm-ag company-web company-tern))))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; custom-set-fase は M-x customize-face で起動できる
                                        ;(custom-set-faces
;; custom-set-faces was added by Custom.
;; If you edit it by hand, you could mess it up, so be careful.
;; Your init file should contain only one such instance.
;; If there is more than one, they won't work right.
                                        ;'(company-preview-common ((t (:inherit company-preview :foreground "lightgrey"))))
                                        ;'(company-scrollbar-bg ((t (:background "gray40"))))
                                        ;'(company-scrollbar-fg ((t (:background "orange"))))
                                        ;'(company-tooltip ((t (:background "lightgrey" :foreground "black"))))
                                        ;'(company-tooltip-selection ((t (:background "steelblue")))))

;;; 自分関数
(defun my/copy-current-path ()
  "Copy the current buffer's file path or dired path to 'kill-ring'.Result is full path."
  (interactive)
  (let ((fPath (if (equal major-mode 'dired-mode) default-directory (buffer-file-name))))
    (when fPath
      (message "stored path: %s" fPath)
      (kill-new (file-truename fPath)))))
(global-set-key [C-f1] 'my/copy-current-path)
(define-key my-helm-map (kbd "p") 'my/copy-current-path)


;;; fill-paragraphをトグルにする
;; M-q で実行
(defun toggle-fill-and-unfill ()
  "Toggle fill and unfill paragraph."
  (interactive)
  (let ((fill-column
         (if (eq last-command 'toggle-fill-and-unfill)
             (progn (setq this-command nil)
                    (point-max))
           fill-column)))
    (call-interactively #'fill-paragraph)))
(global-set-key [remap fill-paragraph] #'toggle-fill-and-unfill)


;;; dired で新しいバッファを開かないようにする
;; http://nishikawasasaki.hatenablog.com/entry/20120222/1329932699 を参考に dired-upを追加
;; https://qiita.com/ballforest/items/0ddbdfeaa9749647b488 でdiredを強化する予定
;; ファイルならelscreen上の別バッファで、ディレクトリなら同じバッファで開く
;; ubuntu でのmouse-1が取れていない
(defun dired-find-alternate-file2 ()
  "In Dired, visit this file or directory instead of the Dired buffer."
  (interactive)
  (set-buffer-modified-p nil)
  (let* ((dired-path (dired-get-file-for-visit))
         (dired-fname (file-name-nondirectory dired-path))
         (dired-dir (directory-file-name dired-path))
         (dired-path2 (cond ((string= dired-fname ".") dired-dir)
                            ((string= dired-fname "..") (directory-file-name dired-dir))
                            (t dired-path))))
    (find-alternate-file dired-path2)))
(defun dired-open-in-accordance-with-situation ()
  "In Direed.  Open in accordance with situation."
  (interactive)
  (let ((file (dired-get-file-for-visit)))
    (if (file-directory-p file)
        (dired-find-alternate-file2)
      (let ((find-file-run-dired t)) (elscreen-find-file (dired-get-file-for-visit))))))
(defun dired-up-directory-open-in-accordance-with-situation ()
  "In Dired, visit up directory instead of the Dired buffer."
  (interactive)
  (let* ((dir (dired-current-directory))
         (up (file-name-directory (directory-file-name dir))))
    (or (dired-goto-file (directory-file-name dir)))
    (set-buffer-modified-p nil)
    (find-alternate-file up)))
(defun dired-mouse-find-file (event)
  "In Dired,  visit the file or directory name you click on.  EVENT."
  (interactive "e")
  (let (window pos file)
    (save-excursion
      (setq window (posn-window (event-end event))
            pos (posn-point (event-end event)))
      (if (not (windowp window))
          (error "No file chosen"))
      (set-buffer (window-buffer window))
      (goto-char pos)
      (setq file (dired-get-file-for-visit)))
    (dired-open-in-accordance-with-situation)))
(define-key dired-mode-map [mouse-1] 'dired-mouse-find-file)
(put 'dired-find-alternate-file 'disabled nil) ;; dired-find-alternate-file の有効化
;; RET 標準の dired-find-file では dired バッファが複数作られるので
(define-key dired-mode-map (kbd "RET") 'dired-open-in-accordance-with-situation) ;; dired-find-alternate-file を代わりに使う
(define-key dired-mode-map (kbd "a") 'dired-find-file)
;; ディレクトリの移動キーを追加(wdired 中は無効)
(define-key dired-mode-map (kbd "<left>") 'dired-up-directory-open-in-accordance-with-situation)
(define-key dired-mode-map (kbd "<right>") 'dired-open-in-accordance-with-situation)
(define-key dired-mode-map (kbd "DEL") 'dired-up-directory-open-in-accordance-with-situation)
(put 'dired-find-alternate-file 'disabled nil)


;;; 括弧の処理
;;; rainbow-delimiters
(show-paren-mode t)                  ; 対応する括弧を光らせる
(unless (require 'rainbow-delimiters nil t) (package-install 'rainbow-delimiters))
(add-hook 'prog-mode-hook 'rainbow-delimiters-mode)
(require 'cl-lib) ;; 括弧の色を強調する設定
(require 'color)
(defun rainbow-delimiters-using-stronger-colors ()
  "Rainbow delimiters using stronger colors."
  (interactive)
  (cl-loop
   for index from 1 to rainbow-delimiters-max-face-count
   do
   (let ((face (intern (format "rainbow-delimiters-depth-%d-face" index))))
     (cl-callf color-saturate-name (face-foreground face) 30))))
(add-hook 'emacs-startup-hook 'rainbow-delimiters-using-stronger-colors)
;;; 括弧の自動挿入
(electric-pair-mode 1)


;;; migemo
;;; 環境依存するのでとりあえずコメントアウト
;; (require 'migemo)
;; (setq migemo-dictionary (expand-file-name "~/.emacs.d/dict/cp932/migemo-dict"))
;; ;;(setq migemo-dictionary (expand-file-name "~/.emacs.d/migemo/dict/cp932/migemo-dict"))
;; ;;;(setq migemo-dictionary (expand-file-name "~/.emacs.d/conf/migemo/dict/utf-8/migemo-dict") ; 文字コードに注意.
;; (setq migemo-command "cmigemo")
;; (setq migemo-options '("-q" "--emacs" "-i" "\a")) (setq migemo-user-dictionary nil) (setq migemo-regex-dictionary nil)
;; ;;;(setq migemo-coding-system 'utf-8-unix) ; 文字コードに注意.
;; (setq migemo-coding-system 'cp932-unix)
;; (load-library "migemo") ; ロードパス指定.
;; (migemo-init)
;; (helm-migemo-mode 1) ;; occurでmigemoが使える


;;; やること TODO
;;; http://sheephead.homelinux.org/2011/12/19/6930/
;;; https://github.com/magnars/multiple-cursors.el マルチ編集
;;; https://github.com/chikatoike/SublimeTextWiki/wiki/SublimeText-Vim-Emacs-%E3%83%97%E3%83%A9%E3%82%B0%E3%82%A4%E3%83%B3%E6%AF%94%E8%BC%83%E8%A1%A8 ここを参考に最強を目指すのだ
;; http://blog.lambda-consulting.jp/2015/11/20/article/ これいいかも。init.elをorgで管理
;; http://d.hatena.ne.jp/rubikitch/20090219/sequential_command 一つのコマンドに複数の意味をもたせる C-a = beginning line buffer 元の位置

;;; 環境依存系の設定
;;; windowsのキーバインドをemacs化するには keyhacが使える
;;; http://qiita.com/hshimo/items/2f3f7e070ae75243eb8b

;;; terminalの時の設定
(when (eq window-system nil)
  (menu-bar-mode -1) ;; メニューバーを非表示
  (define-key global-map [select] 'end-of-line) ;;teraterm,rloginでendキーが効かないのでこれ入れておく

  ;;マウストラッキング
  ;; terminalでホイルスクロール、マウスクリックが使えるようになる。
  ;; 他のwindowとのコピペ時にはctrl押したり(teraterm),メニューで切り替えたりする必要あり(rlogin)
  (xterm-mouse-mode t)
  (when (require 'mwheel nil 'noerror) (mouse-wheel-mode t))
  (global-set-key [mouse-4] '(lambda () (interactive) (scroll-down 3)))
  (global-set-key [mouse-5] '(lambda () (interactive) (scroll-up   3)))
  )

;;; window-systemで立ち上がった時の設定
;;; http://hico-horiuchi.hateblo.jp/entry/20130415/1366010165 ; 分岐
;;; macのときは https://github.com/railwaycat/homebrew-emacsmacport で入れる
(when window-system
  (tool-bar-mode 0)
  (require 'linum)  ;;行番号表示
  (global-linum-mode t);; 常にlinum-modeを有効

  (setq select-active-regions nil)
  (setq mouse-drag-copy-region t)
  ;;(setq x-select-enable-primary t)
  ;;(setq x-select-enable-clipboard nil)

  ;; リージョンの色を変える
  (set-face-background 'region "SeaGreen")

  ;; mode-line (powerline)
  (when (maybe-require-package 'powerline)
    (powerline-default-theme)) ;;とりあえずデフォルト

  )

;; Windows
(when (and window-system (eq system-type 'windows-nt))  ;windowsだったら
  ;; http://blog.syati.info/post/make_windows_emacs/ ;windowsの設定はこのURLでOK
  ;; ショートカットで直接実行するとpathの設定がダメなので
  ;; これで実行するようにする  "C:\gnupack\startup_emacs.exe"
  (setq shell-file-name "bash")
  (setenv "SHELL" shell-file-name)
  (setq explicit-shell-file-name shell-file-name)
  )

;; MACだったら
(when (and window-system (eq system-type 'darwin))
    (mac-auto-ascii-mode 1) ;; ime入力中にC-xoで「お」が表示されないようにする（ただしIMEはoffになる）
    (define-key global-map [?¥] [?\\]) ;; macのemacsではバックスラッシュのキーで円が入る
    (setq mac-option-modifier 'super) ;; option を superへ
    ;; when using Windows keyboard on Mac, the insert key is mapped to <help>
    (global-set-key [C-help] #'clipboard-kill-ring-save)
    (global-set-key [S-help] #'clipboard-yank)
    (global-set-key [help] #'overwrite-mode) ;; insert to toggle `overwrite-mode'
    (define-key global-map (kbd "s-¥") [?\\]) ;; 一応 optionでもでるように
    (define-key global-map (kbd "<s-left>") 'elscreen-previous)
    (define-key global-map (kbd "<s-right>") 'elscreen-next)
    (define-key global-map (kbd "M-{") 'elscreen-previous)
    (define-key global-map (kbd "M-}") 'elscreen-next)
    (define-key global-map (kbd "M-c") 'kill-ring-save)
    (define-key global-map (kbd "M-v") 'yank)
    (define-key global-map (kbd "M-g M-g") 'keyboard-quit)
    (setq save-interprogram-paste-before-kill t)
    )

;; Linux
(when (and window-system (eq system-type 'gnu/linux))

  (setq x-select-enable-primary t)
  ;;(setq x-select-enable-clipboard nil)
  (setq x-select-enable-clipboard t)
  (define-key global-map (kbd "<s-left>") 'elscreen-previous)
  (define-key global-map (kbd "<s-right>") 'elscreen-next)

  ;; ibus.el
  ;; 本当はこれをやりたいが xrdbを実行すると起動後にフォントサイズが変わってしまう→中止
  ;; x側からフォrントを変えるか、emacsがわでXIMをOFFにできるかをやる
  ;; (cd ~/.emacs.d/; wget https://img.atwikiimg.com/www11.atwiki.jp/s-irie/attach/21/95/ibus-el-0.3.2.tar.gz ;tar xf ibus-el-0.3.2.tar.gz ibus-el-0.3.2/ibus.el ibus-el-0.3.2/ibus-el-agent )
  ;; echo 'Emacs*useXIM: false' >> ~/.Xresources
  ;; xrdb ~/.Xresources
  ;;(when (file-exists-p (expand-file-name "~/.emacs.d/ibus-el-0.3.2/ibus.el"))
  ;; (require 'ibus)
  ;; (add-hook 'after-init-hook 'ibus-mode-on)
  ;; (ibus-define-common-key ?\C-\s nil);; C-SPC は Set Mark に使う
  ;; (setq ibus-cursor-color '("red" "blue" "limegreen"));; IBusの状態によってカーソル色を変化させる
  ;; (ibus-define-common-key ?\C-j t);; C-j で半角英数モードをトグルする
  ;; (setq ibus-prediction-window-position t);; カーソルの位置に予測候補を表示
  ;; (setq ibus-undo-by-committed-string t);; Undo の時に確定した位置まで戻る
  ;; (setq ibus-isearch-cursor-type 'hollow);; インクリメンタル検索中のカーソル形状を変更する
  ;;)

  ;; ime linuxのみ mozcで入力
  ;;http://d.hatena.ne.jp/kitokitoki/20120925/p2
  ;; mozc-toolsを入れる
  ;;LANG=ja_JP.UTF-8  /usr/lib/mozc/mozc_tool -mode=config_dialog
  ;;https://yo.eki.do/notes/emacs-windows-2017
  )


;; font
;; http://qiita.com/melito/items/238bdf72237290bc6e42
;; https://qiita.com/segur/items/50ae2697212a7bdb7c7f mac
;; fc-cache -fv でキャッシュを行う
;; ずれ確認用
;; 0123456789012345678901234567890123456789
;; ｱｲｳｴｵｱｲｳｴｵｱｲｳｴｵｱｲｳｴｵｱｲｳｴｵｱｲｳｴｵｱｲｳｴｵｱｲｳｴｵ
;; あいうえおあいうえおあいうえおあいうえお
(when (and window-system (or (file-exists-p (expand-file-name "~/.fonts/Ricty-Regular.ttf")) (file-exists-p (expand-file-name "~/Library/Fonts/Ricty-Regular.ttf"))))
  (let* ((size 12)
         (asciifont "Ricty")
         (jpfont "Ricty")
         (h (* size 10))
         (fontspec (font-spec :family asciifont))
         (jp-fontspec (font-spec :family jpfont)))
    (set-face-attribute 'default nil :family asciifont :height h)
    (set-fontset-font nil 'japanese-jisx0213.2004-1 jp-fontspec)
    (set-fontset-font nil 'japanese-jisx0213-2 jp-fontspec)
    (set-fontset-font nil 'katakana-jisx0201 jp-fontspec)
    (set-fontset-font nil '(#x0080 . #x024F) fontspec)
    (set-fontset-font nil '(#x0370 . #x03FF) fontspec)))

(provide 'init)

;;; init.el ends here
