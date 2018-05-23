# emacs.init

emacsの起動ファイル

## 特徴

- 最初の起動時に必要なパッケージをネットから取ってきます
- helmはemacsの使用感を変えてしまいますが、絞り込みはスペース区切りで任意、C-jで部分確定と覚えると便利です。ディレクトリを上がるときにはC-l
- helmは全般的にC-;にマッピングされていますが、C-;C-;は直前のelscreenのタブです。
- C-xbはhelm-miniにバインドされており、ファイル・バッファ選択時にはelscreenで別タブで開きます
- C-xkはkill-bufferした後(除:*scratch*バッファ)、elscreenのタブを閉じます
- undo(C-/),redo(M-/),undo-tree(C-xu)
- silver searcher(ag)に対応 C-xg 、C-uC-xgをすると起点ディレクトリを指定できます
- gnu globalに対応してます。
- diredは同一バッファで動作します（カーソルキー左右でディレクトリを移動できます）
- saveplaceにて最後に開いたカーソル位置を記憶していますが 一度 M-x toggle-save-placeを実行しないと動かないかもしれません。（未確認）
- マウストラッキングに対応してるのでターミナルでもマウスが使えます(winではRlogin推奨)
- org-modeを若干拡張してます。C-cpでpictureモードになり、作図に便利にしています
- window動作時には"Ricty"フォントを使うようにしています。(macを除く)
- windows(WSL),linux,macで動作します。
- 直前の編集ファイル、一時ファイルは ~/.emacs.d/backupに作成されます（なければ作成します）
- 全角スペース、tabを可視化
- 括弧のカラー化、対応括弧の表示
- companyによる補完

### javascript支援

- ternを用いた補完支援

`sudo npm install -g tern` を実行しておくと設定を行う

tern-modeのショートカットキー

- M-. 定義ジャンプ
- M-, 定義ジャンプから戻る
- C-c C-r 変数名のリネーム
- C-c C-c 型の取得
- C-c C-d docsの表示

## インストール方法

### はじめてのとき

- clone後、シンボリックリンクを作れば良い

```bash
cd ~/.emacs.d/
git clone https://github.com/n9d/emacs.init.git
ln -s emacs.init/init.el .
```

#### ubuntuの場合

- フォントがrictyのため .fonts以下にritcyフォントをおく おいたあとは`fc-cache -fv` http://www.rs.tus.ac.jp/yyusa/ricty.html
- C-; がimeのクリップボード選択になっているので解除する http://citrras.com/archives/1336
- ターミナルでC-;(ctrl+semicolon)がほしいときにはxtermをインストールする( C-;を"\030@c;" )

### windowsの場合

- WSLのときにはwindowモードで動かすならばVcXsrvが必要。(他はubuntuに準拠)
- ターミナル使用時にはRLogin.exeを用いるとC-;が利用可能( C-;を"\030@c;" )

### macの場合

- 手元にmacがないが多分動くはず


### アップデートのとき

- 通常はgit pullだけで良さそうだが、パッケージ周りの問題が起こったときelpaを全部消すと最初からインストールします。

```bash
rm -rf ~/.emacs.d/elpa
cd ~/.emacs.d/emacs.init
git pull
```

## 問題点

- ubuntuでmouse-1を入れ替えることができていない
