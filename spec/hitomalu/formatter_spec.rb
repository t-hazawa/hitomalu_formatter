RSpec.describe Hitomalu::Formatter do

    describe '期待された状態にフォーマットされるか' do
      subject { Hitomalu::Formatter.format(input) }

      context 'テストケース1' do
        let(:input) { '<div>      
<p id="kore_id" 
hgeg2>

nakami
  </p><span>2つ目</span></div><a     href="hoge">fuga</a>
  
  
  <pre>        (スペース4つ)
         (a c)
           ||
           人　←全角スペース
           
           
</pre>
  
  <!-- コメントしてみた -->
<saigo>aaaa</saigo>' }
        
        let(:expected) { "<div>\r\n<p id=\"kore_id\" hgeg2>nakami</p>\r\n<span>2つ目</span>\r\n</div>\r\n<a href=\"hoge\">fuga</a>\r\n<pre>        (スペース4つ)\r\n         (a c)\r\n           ||\r\n           人　←全角スペース\r\n           \r\n           \r\n</pre>\r\n<!-- コメントしてみた -->\r\n<saigo>aaaa</saigo>" }
        it { is_expected.to eq expected }
        
        describe '2回formatしても同じか' do
          let(:input2) { Hitomalu::Formatter.format(input) }
          it { expect(Hitomalu::Formatter.format(input2)).to eq expected }
        end
      end

      context 'テストケース2' do
        let(:input) { 'foo bar <div>baz<span>quux</span> <b>hi</b><span>quux2</span></div>' }
        let(:expected) { "<p>foo bar</p>\r\n<div>baz<span>quux</span> <b>hi</b><span>quux2</span>\r\n</div>" }
        it { is_expected.to eq expected }

        describe '2回formatしても同じか' do
          let(:input2) { Hitomalu::Formatter.format(input) }
          it { expect(Hitomalu::Formatter.format(input2)).to eq expected }
        end
      end

      context 'テストケース3' do
        let(:input) { '<p>チェック検証用</p>
<h2>概要</h2>
<p>タグの外側の空白や</p>
<p>最初のでは</p>
<div>






                   <p>すごくインデント</p>




<p>この文章の前に改行やインデント</p>
</div>

<div><p><b>ここは1行で書いた</b></p></div>' }
        let(:expected) { "<p>チェック検証用</p>\r\n<h2>概要</h2>\r\n<p>タグの外側の空白や</p>\r\n<p>最初のでは</p>\r\n<div>\r\n<p>すごくインデント</p>\r\n<p>この文章の前に改行やインデント</p>\r\n</div>\r\n<div>\r\n<p><b>ここは1行で書いた</b>\r\n</p>\r\n</div>" }
        it { is_expected.to eq expected }

        describe '2回formatしても同じか' do
          let(:input2) { Hitomalu::Formatter.format(input) }
          it { expect(Hitomalu::Formatter.format(input2)).to eq expected }
        end
      end

      context 'テストケース4' do
        let(:input) { '<p>チェック検証用</p>
<h2>概要</h2>
<p>タグの外側の空白や</p>
<p>最初のでは</p>
<div>
<p>すごくインデント</p>
<p>この文章の前に改行やインデント</p>
</div>
<div>
    <p>
        <b>ここは1行で書いた</b>
    </p>
</div>' }
        let(:expected) { "<p>チェック検証用</p>\r\n<h2>概要</h2>\r\n<p>タグの外側の空白や</p>\r\n<p>最初のでは</p>\r\n<div>\r\n<p>すごくインデント</p>\r\n<p>この文章の前に改行やインデント</p>\r\n</div>\r\n<div>\r\n<p><b>ここは1行で書いた</b>\r\n</p>\r\n</div>" }
        it { is_expected.to eq expected }

        describe '2回formatしても同じか' do
          let(:input2) { Hitomalu::Formatter.format(input) }
          it { expect(Hitomalu::Formatter.format(input2)).to eq expected }
        end
      end

      context 'テストケース5' do
        let(:input) { '<details><summary>ほげ</summary>ほげ ほげ</details>
<div>ほげ<p>ほげ</p>ほげ</div>' }
        let(:expected) { "<details>\r\n<summary>ほげ</summary>\r\nほげ ほげ</details>\r\n<div>ほげ\r\n<p>ほげ</p>\r\nほげ</div>" }
        it { is_expected.to eq expected }

        describe '2回formatしても同じか' do
          let(:input2) { Hitomalu::Formatter.format(input) }
          it { expect(Hitomalu::Formatter.format(input2)).to eq expected }
        end
      end

      context 'テストケース6(入れ子)' do
        let(:input) { '<details><summary>折りたたんでも表示される部分</summary>折りたたまれている部分。
<details><summary>入れ子1</summary>入れ子1の内容。
<details><summary>入れ子2-1</summary>入れ子2-1の内容。</details><details>
<summary>入れ子2-2</summary>入れ子2-2の内容。</details></details></details>' }
        let(:expected) { "<details>\r\n<summary>折りたたんでも表示される部分</summary>\r\n折りたたまれている部分。\r\n<details>\r\n<summary>入れ子1</summary>\r\n入れ子1の内容。\r\n<details>\r\n<summary>入れ子2-1</summary>\r\n入れ子2-1の内容。</details>\r\n<details>\r\n<summary>入れ子2-2</summary>\r\n入れ子2-2の内容。</details>\r\n</details>\r\n</details>" }
        it { is_expected.to eq expected }

        describe '2回formatしても同じか' do
          let(:input2) { Hitomalu::Formatter.format(input) }
          it { expect(Hitomalu::Formatter.format(input2)).to eq expected }
        end
      end

      context 'テストケース7' do
        let(:input) { '<table><tbody><tr><td>hoge</td></tr><tr><td>hoge</td></tr></tbody></table>' }
        let(:expected) { "<table>\r\n<tbody>\r\n<tr>\r\n<td>hoge</td>\r\n</tr>\r\n<tr>\r\n<td>hoge</td>\r\n</tr>\r\n</tbody>\r\n</table>" }
        it { is_expected.to eq expected }

        describe '2回formatしても同じか' do
          let(:input2) { Hitomalu::Formatter.format(input) }
          it { expect(Hitomalu::Formatter.format(input2)).to eq expected }
        end
      end

      context 'テストケース8' do
        let(:input) { '<details>
<summary>Details</summary>




    Something  small




</details>' }
        let(:expected) { "<details>\r\n<summary>Details</summary>\r\nSomething small</details>" }
        it { is_expected.to eq expected }

        describe '2回formatしても同じか' do
          let(:input2) { Hitomalu::Formatter.format(input) }
          it { expect(Hitomalu::Formatter.format(input2)).to eq expected }
        end
      end

      context 'テストケース9' do
        let(:input) { '<h3>hoge1</h3><p>hoge</p><p>hoge</p><p>hoge</p>
<h3>hoge2</h3><h3>hoge3</h3>' }
        let(:expected) { "<h3>hoge1</h3>\r\n<p>hoge</p>\r\n<p>hoge</p>\r\n<p>hoge</p>\r\n<h3>hoge2</h3>\r\n<h3>hoge3</h3>" }
        it { is_expected.to eq expected }

        describe '2回formatしても同じか' do
          let(:input2) { Hitomalu::Formatter.format(input) }
          it { expect(Hitomalu::Formatter.format(input2)).to eq expected }
        end
      end

      context 'テストケース10' do
        let(:input) { '<h3>hoge1</h3>
<p>hoge</p>
<p>hoge</p>
<p>hoge</p>
<h3>hoge2</h3>
<h3>hoge3</h3>' }
        let(:expected) { "<h3>hoge1</h3>\r\n<p>hoge</p>\r\n<p>hoge</p>\r\n<p>hoge</p>\r\n<h3>hoge2</h3>\r\n<h3>hoge3</h3>" }
        it { is_expected.to eq expected }

        describe '2回formatしても同じか' do
          let(:input2) { Hitomalu::Formatter.format(input) }
          it { expect(Hitomalu::Formatter.format(input2)).to eq expected }
        end
      end

      context 'テストケース11' do
        let(:input) { '<details>
    <summary>Details</summary>
    Something small enough to escape casual notice.
</details>' }
        let(:expected) { "<details>\r\n<summary>Details</summary>\r\nSomething small enough to escape casual notice.</details>" }
        it { is_expected.to eq expected }

        describe '2回formatしても同じか' do
          let(:input2) { Hitomalu::Formatter.format(input) }
          it { expect(Hitomalu::Formatter.format(input2)).to eq expected }
        end
      end

      context 'テストケース12(ルビもインライン要素扱いなので直後の改行を保持する)' do
        let(:input) { '<ruby>漢<rp>(</rp>
<rt>かん</rt>
<rp>)</rp>
 
字<rp>(</rp>
<rt>じ</rt>
<rp>)</rp>
</ruby>' }
        let(:expected) { "<ruby>漢<rp>(</rp>\r\n<rt>かん</rt>\r\n<rp>)</rp>字<rp>(</rp>\r\n<rt>じ</rt>\r\n<rp>)</rp>\r\n</ruby>" }
        it { is_expected.to eq expected }

        describe '2回formatしても同じか' do
          let(:input2) { Hitomalu::Formatter.format(input) }
          it { expect(Hitomalu::Formatter.format(input2)).to eq expected }
        end
      end

      context 'テストケース13' do
        let(:input) { '<div><p>hoge</p></div>' }
        let(:expected) { "<div>\r\n<p>hoge</p>\r\n</div>" }
        it { is_expected.to eq expected }

        describe '2回formatしても同じか' do
          let(:input2) { Hitomalu::Formatter.format(input) }
          it { expect(Hitomalu::Formatter.format(input2)).to eq expected }
        end
      end

      context 'テストケース14(改行タグ)' do
        let(:input) { '最初の行<br><div id="hoge">次の行<br/>さらに次の行<br     /><p>pの中<wbr>pの2行目</p>aaa<wbr>bbb<wbr>ccc</div>
ここはBRではないがHTMLは改行' }
        let(:expected) { "<p>最初の行<br>\r\n</p>\r\n<div id=\"hoge\">次の行<br>\r\nさらに次の行<br>\r\n<p>pの中<wbr>pの2行目</p>\r\naaa<wbr>bbb<wbr>ccc</div>\r\nここはBRではないがHTMLは改行" }
        it { is_expected.to eq expected }

        describe '2回formatしても同じか' do
          let(:input2) { Hitomalu::Formatter.format(input) }
          it { expect(Hitomalu::Formatter.format(input2)).to eq expected }
        end
      end

      # https://agohack.com/html-closetags/ https://tech.amefure.com/web-html-endtag
      context 'テストケース15(閉じタグを省略できるタグ)' do
        let(:input) { '<a href="example.com"><p>pタグも閉じるのを省略してみた</a>
<table>
<thead>
<tr>
  <th>th1
  <th>th2
  <th>th3
<tbody>
<tr>
  <td>td1-1
  <td>td1-2
  <td>td1-3
<tr>
  <td>td2-1
  <td>td2-2
  <td>td2-3
</table>' }
        let(:expected) { "<a href=\"example.com\">\r\n<p>pタグも閉じるのを省略してみた</p>\r\n</a>\r\n<table>\r\n<thead>\r\n<tr>\r\n<th>th1</th>\r\n<th>th2</th>\r\n<th>th3</th>\r\n</tr>\r\n</thead>\r\n<tbody>\r\n<tr>\r\n<td>td1-1</td>\r\n<td>td1-2</td>\r\n<td>td1-3</td>\r\n</tr>\r\n<tr>\r\n<td>td2-1</td>\r\n<td>td2-2</td>\r\n<td>td2-3</td>\r\n</tr>\r\n</tbody>\r\n</table>" }
        it { is_expected.to eq expected }

        describe '2回formatしても同じか' do
          let(:input2) { Hitomalu::Formatter.format(input) }
          it { expect(Hitomalu::Formatter.format(input2)).to eq expected }
        end
      end

      context 'テストケース16(特にwbr)' do
        let(:input) { '<a></a><abbr></abbr><acronym></acronym><b></b><blockquote></blockquote>
                    <br><br><center></center><cite></cite><code></code><dd>nakami</dd><del></del>
                    <dfn></dfn><div></div><dl></dl><dt></dt><em></em><h2></h2><h3></h3><h4></h4>
                    <h5></h5><h6></h6><hr><i></i><iframe></iframe><ins></ins><img><kbd></kbd>
                    <nobr></nobr><ol><li></li></ol><p></p><pre></pre><q></q><s></s><samp></samp><span></span><strike></strike>
                    <strong></strong><sub></sub><sup></sup><tt></tt><u></u><ul></ul><var></var><wbr>
                    <table><caption></caption><thead></thead><colgroup><col></colgroup><tbody><tr>
                    <td></td><th></th></tr></tbody><tfoot></tfoot></table>' }
        let(:expected) { "<a></a><abbr></abbr><acronym></acronym><b></b>\r\n<blockquote></blockquote>\r\n<br>\r\n<br>\r\n<center></center>\r\n<cite></cite><code></code>\r\n<dd>nakami</dd>\r\n<del></del>\r\n<dfn></dfn>\r\n<div></div>\r\n<dl></dl>\r\n<dt></dt>\r\n<em></em>\r\n<h2></h2>\r\n<h3></h3>\r\n<h4></h4>\r\n<h5></h5>\r\n<h6></h6>\r\n<hr>\r\n<i></i><iframe></iframe><ins></ins><img><kbd></kbd>\r\n<nobr></nobr>\r\n<ol>\r\n<li></li>\r\n</ol>\r\n<p></p>\r\n<pre></pre>\r\n<q></q><s></s><samp></samp><span></span>\r\n<strike></strike>\r\n<strong></strong><sub></sub><sup></sup><tt></tt><u></u>\r\n<ul></ul>\r\n<var></var><wbr>\r\n<table>\r\n<caption></caption>\r\n<thead></thead>\r\n<colgroup>\r\n<col>\r\n</colgroup>\r\n<tbody>\r\n<tr>\r\n<td></td>\r\n<th></th>\r\n</tr>\r\n</tbody>\r\n<tfoot></tfoot>\r\n</table>" }
        it { is_expected.to eq expected }

        describe '2回formatしても同じか' do
          let(:input2) { Hitomalu::Formatter.format(input) }
          it { expect(Hitomalu::Formatter.format(input2)).to eq expected }
        end
      end

      context 'テストケース17(改行が増殖しないか)' do
        let(:input) { 'ほげ
<div>ほげ<p>ほげ<span>ほげ</span>ほげ</p>ほげ<p>ほげ</p>ほげ</div>ほげ
ほげ' }
        let(:expected) { "<p>ほげ</p>\r\n<div>ほげ\r\n<p>ほげ<span>ほげ</span>ほげ</p>\r\nほげ\r\n<p>ほげ</p>\r\nほげ</div>\r\nほげ ほげ" }
        it { is_expected.to eq expected }

        describe '2回formatしても同じか' do
          let(:input2) { Hitomalu::Formatter.format(input) }
          it { expect(Hitomalu::Formatter.format(input2)).to eq expected }
        end
      end

      context 'テストケース18(タグの中身の整形 - preはそのまま)' do
        let(:input) { '<pre>
    pre はその     まま
  pre    2    行    目   
     </pre>' }
        let(:expected) { "<pre>\r\n    pre はその     まま\r\n  pre    2    行    目   \r\n     </pre>" }
        it { is_expected.to eq expected }

        describe '2回formatしても同じか' do
          let(:input2) { Hitomalu::Formatter.format(input) }
          it { expect(Hitomalu::Formatter.format(input2)).to eq expected }
        end
      end

      context 'テストケース19(タグの中身の整形 - pは整形される)' do
        let(:input) { '<p>
    p は整形     される
  p    2    行    目   
  全角　　　スペース3つ
     </p>' }
        let(:expected) { "<p>p は整形 される p 2 行 目 全角　　　スペース3つ</p>" }
        it { is_expected.to eq expected }

        describe '2回formatしても同じか' do
          let(:input2) { Hitomalu::Formatter.format(input) }
          it { expect(Hitomalu::Formatter.format(input2)).to eq expected }
        end
      end

      context 'テストケース20(コメントの中身は整形しない)' do
        let(:input) { '<p>
  コメントの前の文字列
</p>
<!--       
    コメント はその     まま
  コメント    2    行    目   
     -->' }
        let(:expected) { "<p>コメントの前の文字列</p>\r\n<!--       \r\n    コメント はその     まま\r\n  コメント    2    行    目   \r\n     -->" }
        it { is_expected.to eq expected }

        describe '2回formatしても同じか' do
          let(:input2) { Hitomalu::Formatter.format(input) }
          it { expect(Hitomalu::Formatter.format(input2)).to eq expected }
        end
      end

      context 'テストケース21(タグが大文字で書かれている場合は小文字になる)' do
        let(:input) { '<DiV><P>nakami</P></DiV>' }
        let(:expected) { "<div>\r\n<p>nakami</p>\r\n</div>" }
        it { is_expected.to eq expected }

        describe '2回formatしても同じか' do
          let(:input2) { Hitomalu::Formatter.format(input) }
          it { expect(Hitomalu::Formatter.format(input2)).to eq expected }
        end
      end

      context 'テストケース22(<br /> や <hr /> が <br> や <hr> になるか)' do
        let(:input) { '<div>1行目<br />2行目<hr />3行目</div>' }
        let(:expected) { "<div>1行目<br>\r\n2行目\r\n<hr>\r\n3行目</div>" }
        it { is_expected.to eq expected }

        describe '2回formatしても同じか' do
          let(:input2) { Hitomalu::Formatter.format(input) }
          it { expect(Hitomalu::Formatter.format(input2)).to eq expected }
        end
      end

      context 'テストケース23(インライン要素の改行 - 改行がなければ勝手に改行されない、1つの改行やスペースは保持される、2つ以上の改行やスペースは1つになる)' do
        let(:input) { '<img src="1.jpg"><img src="2.png"><img src="2_2.png"><img src="2_3.png">
<img src="3.gif">

<img src="4.jpeg">
<img src="5.webp"> <img src="6.jpeg">
<img src="7.jpeg">  <img src="8.jpeg">
    <img src="9.jpeg">      <img src="10.jpeg">
<img src="11.jpeg">' }
        let(:expected) { "<img src=\"1.jpg\"><img src=\"2.png\"><img src=\"2_2.png\"><img src=\"2_3.png\">\r\n<img src=\"3.gif\">\r\n<img src=\"4.jpeg\">\r\n<img src=\"5.webp\"> <img src=\"6.jpeg\">\r\n<img src=\"7.jpeg\"> <img src=\"8.jpeg\">\r\n<img src=\"9.jpeg\"> <img src=\"10.jpeg\">\r\n<img src=\"11.jpeg\">" }
        it { is_expected.to eq expected }

        describe '2回formatしても同じか' do
          let(:input2) { Hitomalu::Formatter.format(input) }
          it { expect(Hitomalu::Formatter.format(input2)).to eq expected }
        end
      end

      context 'テストケース24(インライン要素はコメントノードの次で改行されない)' do
        let(:input) { '<div><span>本文1</span><!-- コメント --><span>本文2</span></div>' }
        let(:expected) { "<div><span>本文1</span><!-- コメント --><span>本文2</span>\r\n</div>" }
        it { is_expected.to eq expected }

        describe '2回formatしても同じか' do
          let(:input2) { Hitomalu::Formatter.format(input) }
          it { expect(Hitomalu::Formatter.format(input2)).to eq expected }
        end
      end

      context 'テストケース25(インライン要素の次に改行があったら保持される)' do
        let(:input) { "<div><span>本文1</span>\r\n  <!-- コメント -->      <span>本文2</span></div>" }
        let(:expected) { "<div><span>本文1</span>\r\n<!-- コメント --> <span>本文2</span>\r\n</div>" }
        it { is_expected.to eq expected }

        describe '2回formatしても同じか' do
          let(:input2) { Hitomalu::Formatter.format(input) }
          it { expect(Hitomalu::Formatter.format(input2)).to eq expected }
        end
      end

      context 'テストケース26(block内での自動改行位置)' do
        let(:input) { '<address><a href="mailto:jim@rock.com">jim@rock.com</a></address>' }
        let(:expected) { "<address><a href=\"mailto:jim@rock.com\">jim@rock.com</a>\r\n</address>" }
        it { is_expected.to eq expected }

        describe '2回formatしても同じか' do
          let(:input2) { Hitomalu::Formatter.format(input) }
          it { expect(Hitomalu::Formatter.format(input2)).to eq expected }
        end
      end

      context 'テストケース27(block内での自動改行位置)' do
        let(:input) { '<address>
  <a href="mailto:jim@rock.com">jim@rock.com</a>
</address>' }
        let(:expected) { "<address><a href=\"mailto:jim@rock.com\">jim@rock.com</a>\r\n</address>" }
        it { is_expected.to eq expected }

        describe '2回formatしても同じか' do
          let(:input2) { Hitomalu::Formatter.format(input) }
          it { expect(Hitomalu::Formatter.format(input2)).to eq expected }
        end
      end

      context 'テストケース28(改行増殖を微修正)' do
        let(:input) { 'ほげ
<div>ほげ<p>ほげ<span>ほげ</span>ほげ</p>ほげ<p>ほげ</p></div>ほげ
ほげ' }
        let(:expected) { "<p>ほげ</p>\r\n<div>ほげ\r\n<p>ほげ<span>ほげ</span>ほげ</p>\r\nほげ\r\n<p>ほげ</p>\r\n</div>\r\nほげ ほげ" }
        it { is_expected.to eq expected }

        describe '2回formatしても同じか' do
          let(:input2) { Hitomalu::Formatter.format(input) }
          it { expect(Hitomalu::Formatter.format(input2)).to eq expected }
        end
      end

      context 'テストケース29(ルビ周りでは改行を挿入しない)' do
        let(:input) { '<p>ほげほげの<ruby>振り仮名<rp>(</rp><rt>ふりがな</rt><rp>)</rp></ruby>がほげほげ。</p>' }
        let(:expected) { "<p>ほげほげの<ruby>振り仮名<rp>(</rp><rt>ふりがな</rt><rp>)</rp></ruby>がほげほげ。</p>" }
        it { is_expected.to eq expected }

        describe '2回formatしても同じか' do
          let(:input2) { Hitomalu::Formatter.format(input) }
          it { expect(Hitomalu::Formatter.format(input2)).to eq expected }
        end
      end

      context 'テストケース30(コメントノードはインライン扱い。改行含む改行スペースあったら改行1個、スペースあったらスペース1個、なにもなければないまま)' do
        let(:input) { '<p>あけまして<!-- コメント -->おめでとう</p>' }
        let(:expected) { "<p>あけまして<!-- コメント -->おめでとう</p>" }
        it { is_expected.to eq expected }

        describe '2回formatしても同じか' do
          let(:input2) { Hitomalu::Formatter.format(input) }
          it { expect(Hitomalu::Formatter.format(input2)).to eq expected }
        end
      end
    end
end
