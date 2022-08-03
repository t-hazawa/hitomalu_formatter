require 'nokogiri'

module Hitomalu
  class Formatter
    CONTENT_NO_MODIFY_TAGS = [ 'pre' ]

    # cf. https://developer.mozilla.org/ja/docs/Web/HTML/Inline_elements
    # rp と rt は上に記載がないが、改行させたくないので追加
    # node.name が 'comment' であるコメントノードもインライン扱い
    INLINE_TAGS = [ 'a', 'abbr', 'acronym', 'audio', 'b', 'bdi', 'bdo', 'big', 'br', 'button', 'canvas', 'cite', 'code', 'comment', 'data', 'datalist', 'del', 'dfn', 'em', 'embed', 'i', 'iframe', 'img', 'input', 'ins', 'kbd', 'label', 'map', 'mark', 'meter', 'noscript', 'object', 'output', 'picture', 'progress', 'q', 'rp', 'rt', 'ruby', 's', 'samp', 'script', 'select', 'slot', 'small', 'span', 'strong', 'sub', 'sup', 'svg', 'template', 'textarea', 'time', 'u', 'tt', 'var', 'video', 'wbr' ]

    def self.format(html)
      # 改行コード \n を \r\n に統一しておく
      html = html.gsub(/(?<!\r)\n/, "\r\n")

      # Nokogiri は wbr (本来閉じタグをつけてはいけない)があると 勝手に閉じタグをつけ、最悪その後のHTMLをなかったことにしてしまうので、
      # 先回りして、直後に </wbr> をつけておいてしまう (元から含まれる </wbr> を消して、開始タグの直後につける)
      html = html.gsub(/<\s*\/\s*wbr\s*>/, "").gsub(/<\s*wbr\s*>/, "<wbr></wbr>")

      doc = Nokogiri::HTML.parse(html)
      # body で全体が囲われていないと、最上層に兄弟ノードを追加できないのでHTMLFragmentでは不可
      body = doc.at_css('body')

      body.traverse { |node|
        # 中身がないと、li などの閉じタグ省略可能なタグについてNokogiriが閉じタグ省略を行い、整形をかけるたびに閉じタグがついたりなくなったりするので、
        # 中身がないかスペースだけの場合、仮文字列にして最後に空文字列に置換する
        # ただし、 <img src="1.jpg"> <img src="2.jpg"> のようなインライン要素の間のスペースと改行は保持する必要があるので保持する。
        # <li></li> の中に |mykaramojiretsu| を入れるために + ではなく * が必要
        if /\A[ ]*\Z/.match?(node.content) && (node.previous_sibling.nil? || !INLINE_TAGS.include?(node.previous_sibling.name))
          node.content = "|mykaramojiretsu|"
        end

        # インライン要素は、ブロック内先頭やテキストノードやインライン要素の次では改行しない
        # (前がブロック要素の終わりやコメントノードだと改行する)
        if INLINE_TAGS.include?(node.name) && (node.previous_sibling.nil? || (node.previous_sibling.instance_of?(Nokogiri::XML::Text) || INLINE_TAGS.include?(node.previous_sibling.name)))
          node.add_previous_sibling("|nobreakline|")
        end

        # タグ間の改行やスペースを消す(前がインライン要素でなければ)
        if /\A[\s]+\Z/.match?(node.to_s)
          if !node.previous_sibling.nil? && INLINE_TAGS.include?(node.previous_sibling.name)
            # 前がインライン要素なら、複数改行(スペース混じりも)を改行1つにしておく。また連続スペースを1つにする
            if /\r\n/.match?(node.content)
              node.content = node.content.gsub(/(\s)+/, "|mykaigyo|")
            end
            node.content = node.content.gsub(/ {2,}/, " ").gsub(' ', '|myspace|')
          else
            node.content = ""
          end
        end

        # </span>\n</div> を </span>\n</div> のままにしたいが、Nokogiri は閉じタグ間の\nを消すので一旦 |mykaigyo| にする (整形を2回かけた時用)
        if node.instance_of?(Nokogiri::XML::Element) && !node.next_sibling.nil? && /\A\s*(\n|\r\n)\s*\Z/.match?(node.next_sibling.content) && node.next_sibling.next_sibling.nil?
          node.next_sibling.content = "|mykaigyo|"
        end

        # タグの中身を整形する(見やすくするため)
        if node.instance_of?(Nokogiri::XML::Text) && !CONTENT_NO_MODIFY_TAGS.include?(node.parent.name)
          node.content = node.content.strip.gsub(/\s{2,}/, " ")
        end

        # 閉じタグとテキストノードの間に改行がなければ入れる(見やすくするため)
        # (前がインライン要素以外なら。 <- 補足: 今回の場合、テキストノードは1つにまとめられるので、テキストノードの前にテキストノードは来ない...ので判定不要 )
        if node.instance_of?(Nokogiri::XML::Text) && !node.previous_sibling.nil? && !/^(\n|\r\n|\|mykaigyo\||\|mykaramojiretsu\||\|nobreakline\||\|myspace\|)+.*$/.match?(node.content) && !INLINE_TAGS.include?(node.previous_sibling.name)
          if !node.previous_sibling.content.eql?("|nobreakline|")
            node.content = "\r\n" + node.to_s
          end
        end
      }

      # Nokogiriが勝手につける</wbr>を消して、本物の空文字列にして、改行用文字列を本物の改行にして、要らないbodyタグを消し、全体の先頭と最後に改行が付くので消す
      # さらに、Nokogiriがつける改行コード \n も \r\n に統一しておく
      body_str = body.to_s.gsub(/(\|mykaigyo\|)+/, "\r\n").gsub('|myspace|', ' ').gsub(/(<\/wbr>|\|mykaramojiretsu\||\A<body>(\n|\r\n)*|(\n|\r\n)*<\/body>\Z)/, "").gsub(/(?<!\r)\n/, "\r\n")
      
      # </span></div> のような閉じタグの間に改行が無かったら改行を入れる (Nokogiri の add_next_sibling は 20000回するとメモリを6GB以上使うので文字列処理でやる)
      # ただし、</ruby>の前には入れない(</rp>などの短いインライン要素が来るため)
      prev_str = ""
      while body_str != prev_str do
          prev_str = body_str
          body_str = body_str.gsub(/(<\/[a-z]+>)(<\/(?!ruby))/, "\\1\r\n\\2")
      end

      # 開始タグの前に改行がなければ改行を入れる (add_prev_sibling は重いので文字列処理でやる) (文章の先頭からは消す)
      # その後、使い終わった改行しない印を消す
      body_str = body_str.gsub(/(?<!\r\n)(?<!\|nobreakline\|)(?<!\|nobreakline\| )<(?!\/)/, "\r\n<").gsub(/(\A\r\n|\|nobreakline\|)/, "")
      
      # <br> や <hr> や <col> の後ろに改行がなければ改行を入れる (add_next_sibling は重いので文字列処理でやる)
      body_str = body_str.gsub(/(<(?:br|hr|col)>)(?!\r\n)/, "\\1\r\n")
    end
  end
end
