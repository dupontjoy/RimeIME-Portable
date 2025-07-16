## RimeIME Portable

#### 批處理實現Rime小狼毫輸入便攜版

批處理作者：**大水牛** 2013.9.11

<img width="650" src="img/folder-structure.jpg">

#### 個人碼表：倉頡五代

3个custom文件都是必須的

編碼以「z」開頭（兼容漢字「zc」，部首「zr」，筆畫「zs」，表意文字描述字符「zi」，算籌符號「zn」，其他符號「zf」）

#### 重要设置

- 码表中设置 use_preset_vocabulary: false #一定要设置成false，关掉预设词组，才能连打
- weasel.custom.yaml设置
````
patch:
  app_options:
   cmd.exe:
    ascii_mode: true
   conhost.exe:
    ascii_mode: true
   mpv.exe:
    ascii_mode: true
  "style/font_face": "TH-Tshyn-P1,TH-Tshyn-P2"
  "style/comment_font_face": "TH-Tshyn-P1,TH-Tshyn-P2"
  "style/label_font_face": "TH-Tshyn-P1,TH-Tshyn-P2"
````

#### 倉頡輸入法相關書籍

| | |
| :--- | :--- |
| 倉頡敎程 | 一天学会仓颉输入法.pdf |
| | 第五代倉頡輸入法手冊.pdf |
| | 仓颉五代“非韭”等字拆法.docx |
| | 在哪裡切--仓颉.7z |
| | …… |
| 正體字敎程 | 繁體字通俗演義(2010.09.23).pdf |
| | 國字標準字體楷書母稿＜教育部字序＞.pdf |
| | …… |
| 下載地址 | [Book](book/) |

#### Rime輸入法項目

https://github.com/rime/home/wiki

#### 最新码表

https://github.com/Jackchows/Cangjie5