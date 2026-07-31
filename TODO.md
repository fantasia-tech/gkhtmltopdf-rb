# TODO

## 完了 v0.9.0

- [x] 並列処理対応(自動空きportチェック)
- [x] 印刷オプションの追加
- [x] Dockerfileの追加(Debian動作確認)
- [x] PATHエラー時の表示追加
- [x] 入力値検証
- [x] テストカバレッジ100%
- [x] RubyGemsで公開
- [x] 多言語対応について

## 完了 v1.0.0

- [x] 複数ファイル&URLの直列実行による高速化
- [x] エラー処理
- [x] 起動時の待機時間オプション

## 完了 v1.1.0

- [x] UA設定機能の追加
- [x] mktmpdirの明示的な削除

## 完了 v1.1.1

- [x] GeckodriverのSTDOUT/STDERR追加

## 完了 v1.2.0

- [x] pdfをsaveせずバイナリを直接返却するメソッドの追加

## 検討中

- [ ] 設定のStruct化?(default切り出し)
- [ ] 肥大化したconvert.rbの分割( `Gkhtmltopdf::PDF` とかつくるか)
- [ ] ポート範囲設定?
- [ ] YARD追加
- [ ] FireFox timeout
- [ ] configファイルからオプションを設定?
