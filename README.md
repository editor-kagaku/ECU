# ecu_education
本リポジトリは、「ECU入門」の演習用に作成致しました。
演習の手順については、そちらを参照下さい。

# 各演習後の環境例は下記よりダウンロード可能です。
```
https://github.com/editor-kagaku/ECU_Answer
```

7zipで分割して格納しています。
7zipの展開で結合されます。
なお、大学教育用に公開しているため、各zipファイルは暗号化しております。
zipファイルのパスワードについては、下記のメールアドレスにお問い合わせください。
```
editor-kagaku@it-book.co.jp
```

## License
本成果物は、TOPPERSプロジェクトの成果物を活用しております。
そのため、TOPPERSライセンス( https://www.toppers.jp/license.html )の下で公開するものと致します。

# 本書の訂正内容
本書『自動車用ECU開発入門 システム・ハードウェア・ソフトウェアの基本とAUTOSARによる開発演習』の記述に誤りがございました。
謹んでお詫び申し上げますとともに、以下のように訂正申し上げます。科学情報出版（株）

## 訂正内容1

P.146の手順7の変更箇所が抜けておりました。
以下の内容を追記いたします。
★の箇所が変更が必要な箇所です
```
1570:      <INTERNAL-BEHAVIORS>
1571:       <SWC-INTERNAL-BEHAVIOR>
★1572:        <SHORT-NAME>IB_LC</SHORT-NAME>
1573:        <EVENTS>
1574:         <TIMING-EVENT>
★1575:          <SHORT-NAME>LedControl_timingEvent</SHORT-NAME>
★1576:          <START-ON-EVENT-REF DEST="RUNNABLE-ENTITY">/RcCar/AppLedControl/IB_LC/LedControl</START-ON-EVENT-REF>
★1577:          <PERIOD>0.1</PERIOD>
・・・
1582:         <RUNNABLE-ENTITY>
★1583:          <SHORT-NAME>LedControl</SHORT-NAME>
```

## 訂正内容2

P.151　AppLedControl.cの編集について、38行目の表記は正しくは下記の通りです。
```
Rte_Write_LedBlinkOut_state( active_led_val );
```




