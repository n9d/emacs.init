# emacs.init
emacsの起動ファイル

## 特徴

- 最初の起動時に必要なパッケージをネットから取ってきます
- diredは同一バッファで動作します（カーソルキー左右でディレクトリを移動できます）
- C-xbはhelm-miniにバインドされており、ファイル・バッファ選択時にはelscreenで別タブで開きます
- C-xkはkill-bufferした後、elscreenのタブを閉じます
- helmは全般的にC-;にマッピングされていますが、C-;C-;は直前のelscreenのタブです。
- saveplaceにて最後に開いたカーソル位置を記憶していますが 一度 M-x toggle-save-placeを実行しないと動かないかもしれません。（未確認）
- マウストラッキングに対応してるのでターミナルでもマウスが使えます(winではRlogin推奨)
- gnu global,silver searcherに対応してます。
- org-modeを若干拡張してます。C-cpでpictureモードになり、作図に便利にしています
- window動作時には"Ricty"フォントを使うようにしています。(macを除く)
- windows(WSL),linux,macで動作します。
