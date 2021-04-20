# Markdownの見出し

Markdown言語の使い方を練習するファイル。  
記載方法合ってる？

## 参考HP
[Markdown記法 サンプル集](https://qiita.com/tbpgr/items/989c6badefff69377da7)

### 見出し3
"#"を増やすことで、見出し6までいけるっぽい。

## 箇条書き
- リスト1
  - リスト1-1
    - リスト1-1-1
  - リスト1-2
- リスト2

---

1. 番号付きリスト
    1. 番号付きリスト
        1. 番号付きリスト
        1. 番号付きリスト
    1. 番号付きリスト
1. 番号付きリスト

番号付きは自動で番号が割り振られるので、数字は何でもよい。
決まった数字にしておくと入れ替えが便利。

## 引用
> メールと同じ。
> 
>> 二重も行ける


## pre記法
    function edit_profile
    {
    #    notepad $profile
        xyz $profile
    }

スペース4つかタブで出来る。

## code記述
```
function edit_profile
{
#    notepad $profile
    xyz $profile
}
```

PowerShellで `edit_profile` として使う。

## 強調
normal *bold* normal

normal **bold** normal

normal ***bold*** normal

## リンク
[GitHubマイページ](https://github.com/tsu-kunn)

## リンク参照
何回も同じリンクを記述する場合などに使用する。  
[リンク1][GitHub]  
[リンク2][GitHub]

[GitHub]: https://github.com/


# GitHub Flavored Markdown(GFM)
GitHubの独自仕様のMarkdown記法。  
GitHub人気だから、これがメインになってるのかな？

## 取り消し線
これは~~取り消し線~~です。


## シンタックスハイライト
~~~C
int main(int args, char *argc[])
{
	printf("Hello world\n");
	return 1;
}
~~~

~~~ Python
if __name__ == "__main__":
    print("Hello world")
~~~

## 表
|header1|header2|header3|
|:--|--:|:--:|
|align left|align right|align center|
|a|b|c|
|d||f|

結合はできないのかな？


## 使用例

### PowerShellでGitの文字化けを改善
  
環境変数のLANGに文字コードを設定する。

~~~
Set-Item env:LANG -Value ja_JP.UTF-8
~~~
