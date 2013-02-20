#!/bin/sh
#
# はてなからはてなキーワードを取得してskk辞書に変換するスクリプト。
#
# はてなからキーワードリストを受け取り、 hatena-jisyo.cdb という名前で
# cdb形式の辞書にします。
# cronに登録して一ヶ月に一回程度回します。
# これによりSKKでも最新のネットで話題の単語が使えるようになります。
#
# *必要なもの。
# hatena2skk.rb 
# skkdic-expr と skkdic-sort と skk2cdb
# sudo apt-get install skktools で導入可能。
# 
#
# 2012年05月20日(日曜日) 15:04:08 JST
# はてなキーワードcsvファイルが空になっている事に気づいた。
# しょうがないので、ID付きのファイルを落としてきて、IDフィールドをsedで削除する事にした。
# 2012年05月22日(火曜日) 12:58:39 JST
# 今みたらファイルがあったな。wget --spiderオプションで存在の可否を調べてから切り替えるように
# してみた。なければID付きリストをダウンする。


test -x ~/bin/hatena2skk.rb   || exit 0;
test -x /usr/bin/skkdic-expr  || exit 0;
test -x /usr/bin/skkdic-sort  || exit 0;
test -x /usr/bin/skk2cdb      || exit 0;


URL="http://d.hatena.ne.jp/images/keyword/"
HATENAKEY="keywordlist_furigana.csv"
HATENAKEY_ID="keywordlist_furigana_with_kid.csv"
TEMPFILE="key.tmp"
TMPDIC="tmp.skkdic"
JISYO="SKK-hatena-jisyo"
HATENA2SKK="~/bin/hatena2skk.rb"
SKKDIR="~/skk-dic/"

# 標準エラー出力をリダイレクトして渡す。
# --spider はファイルが存在するかチェックするオプション。実際にdownloadはしない。
SIZE=`LANG=C wget --no-proxy --spider ${URL}${HATENAKEY} 2>&1 | grep '^Length: ' | awk '{print $2}'`
if [ $SIZE -eq  0 ]; then
	HATENAKEY=$HATENAKEY_ID
	echo "Download file is ${HATENAKEY}."
	LANG=C wget ${URL}${HATENAKEY}
	if [ -s ${HATENAKEY} ]; then
		cat ${HATENAKEY} | sed 's/\t[0-9][0-9]*$//' > $TEMPFILE
		rm $HATENAKEY
	else
		echo "err.Not File."
		exit 0;
	fi
else
	echo "Download file is ${HATENAKEY}."
	LANG=C wget ${URL}${HATENAKEY}
	mv $HATENAKEY $TEMPFILE
fi

$HATENA2SKK $TEMPFILE > $TMPDIC && \
	skkdic-expr $TMPDIC | skkdic-sort > $JISYO && \
	skk2cdb $JISYO hatena-jisyo.cdb && \
	mv hatena-jisyo.cdb $JISYO $SKKDIR
gzip -f $SKKDIR$JISYO
rm $TMPDIC $TEMPFILE

