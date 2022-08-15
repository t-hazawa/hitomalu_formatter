require 'nokogiri'

module Hitomalu
  class Formatter
    CONTENT_NO_MODIFY_TAGS = [ 'pre' ]

    # cf. https://developer.mozilla.org/ja/docs/Web/HTML/Inline_elements
    # rp と rt は上に記載がないが、改行させたくないので追加
    # node.name が 'comment' であるコメントノードもインライン扱い
    INLINE_TAGS = [ 'a', 'abbr', 'acronym', 'audio', 'b', 'bdi', 'bdo', 'big', 'br', 'button', 'canvas', 'cite', 'code', 'comment', 'data', 'datalist', 'del', 'dfn', 'em', 'embed', 'i', 'iframe', 'img', 'input', 'ins', 'kbd', 'label', 'map', 'mark', 'meter', 'nobr', 'noscript', 'object', 'output', 'picture', 'progress', 'q', 'rp', 'rt', 'ruby', 's', 'samp', 'script', 'select', 'slot', 'small', 'span', 'strong', 'sub', 'sup', 'svg', 'template', 'text', 'textarea', 'time', 'u', 'tt', 'var', 'video', 'wbr' ]
    INLINE_TAGS_REGEXP = INLINE_TAGS.join('|')

    ADD_BREAK_LINE_TAGS = [ 'br', 'hr', 'col' ]
    ADD_BREAK_LINE_TAGS_REGEXP = ADD_BREAK_LINE_TAGS.join('|')

    # フォーマットで改行が増えないタグ (改行が増えるタグで改行増殖を抑えるために使う)
    BREAK_LINE_NOT_INCREASE_TAGS = INLINE_TAGS - ADD_BREAK_LINE_TAGS

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
        # テキストノードが空白文字以外を含み、親が非インライン要素(=ブロックノード)でもpreでもないならば中身の先頭と最後のスペースを消す
        # (親のブロック要素に接しているところ = 兄弟がいない方向のみ)
        if node.instance_of?(Nokogiri::XML::Text) && /\S/.match(node.content) && !(INLINE_TAGS + CONTENT_NO_MODIFY_TAGS).include?(node.parent.name)
          if node.previous_sibling.nil?
            node.content = node.content.gsub(/(\A\s+)/, "")
          end
          if node.next_sibling.nil?
            node.content = node.content.gsub(/(\s+\Z)/, "")
          end
        end


        # 中身がないと、li などの閉じタグ省略可能なタグについてNokogiriが閉じタグ省略を行い、整形をかけるたびに閉じタグがついたりなくなったりするので、
        # 中身がないかスペースだけの場合、仮文字列にして最後に空文字列に置換する
        # <li></li> の中に |mykaramojiretsu| を入れるために + ではなく * が必要
        if /\A[ ]*\Z/.match?(node.content)
          node.content = node.content + "|mykaramojiretsu|"
        end

        # インライン要素は、ブロック内先頭やテキストノードやインライン要素の次では改行しない
        # (前がブロック要素の終わりやコメントノードだと改行する)
        # (前が最後に改行を足すタグの場合、|nobreakline| を足すとスペースが増えて、フォーマットをかける度に結果が変わるので、|nobreakline| を足しません)
        if INLINE_TAGS.include?(node.name) && (node.previous_sibling.nil? || (INLINE_TAGS.include?(node.previous_sibling.name) && !ADD_BREAK_LINE_TAGS.include?(node.previous_sibling.name)))
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

        # この下の処理で先頭改行をスペースに置換している & ブロック要素閉じタグの後には改行を入れる処理の関係上、
        # </summary>\r\nnakami のような ブロック要素閉じタグ直後に改行が来ている場合、スペースが増殖してしまう (= 2回フォーマットをかけると結果が変わってしまう)
        # それを防ぐため、ブロック要素閉じタグ直後の場合は先頭の改行を削除する
        if node.instance_of?(Nokogiri::XML::Text) && !node.previous_sibling.nil? && !BREAK_LINE_NOT_INCREASE_TAGS.include?(node.previous_sibling.name) && !CONTENT_NO_MODIFY_TAGS.include?(node.parent.name)
          node.content = node.content.gsub(/\A *(\r\n|\n)*/, "")
        end
      
        # 上の事を、直後がブロック要素開始タグの場合にも末尾の改行についてする
        if node.instance_of?(Nokogiri::XML::Text) && !node.next_sibling.nil? && !BREAK_LINE_NOT_INCREASE_TAGS.include?(node.next_sibling.name) && !CONTENT_NO_MODIFY_TAGS.include?(node.parent.name)
          node.content = node.content.gsub(/ *(\r\n|\n)*\Z/, "")
        end

        # タグの中身を整形する(見やすくするため)
        # 英文など、スペースが重要な言語があるので、stripはしない (Hello <a href="#world">world</a> のような文でスペースが、stripで無くなってしまう)
        # \r\n を 2文字で1つのもの扱いにするため \s ではなく () で列挙している
        # 連続する改行・スペースをスペース1つにし、先頭と最後の改行・スペースを除去し、文中の改行を除去する
        if node.instance_of?(Nokogiri::XML::Text) && !CONTENT_NO_MODIFY_TAGS.include?(node.parent.name)
          node.content = node.content.gsub(/(\r\n|\n| |\t|\f){2,}/, " ").gsub(/(\A ?(\r\n|\n) ?| ?(\r\n|\n) ?\Z)/, " ").gsub("\r\n", " ")
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
      # ただし、片方または両方がインライン要素の閉じタグだったら入れない
      prev_str = ""
      while body_str != prev_str do
          prev_str = body_str
          body_str = body_str.gsub(/(<\/(?!(#{INLINE_TAGS_REGEXP}))[a-z]+>)(<\/(?!(#{INLINE_TAGS_REGEXP}))[a-z]+>)/, "\\1\r\n\\3")
      end

      # 開始タグの前に改行がなければ改行を入れる (add_prev_sibling は重いので文字列処理でやる) (文章の先頭からは消す)
      # その後、使い終わった改行しない印を消す
       # また、閉じタグしか無い行の先頭のスペースを消す (閉じタグで改行されるのはブロック要素の閉じタグだけであるため、pre以外ならスペースを消して問題ない)
      body_str = body_str.gsub(/(?<!\r\n)(?<!\|nobreakline\|)(?<!\|nobreakline\| )<(?!\/)/, "\r\n<").gsub(/(\A\r\n|\|nobreakline\|)/, "").gsub(/^ *(?!<\/pre>)(<\/[a-z]+>)$/, "\\1")
      
      # <br> や <hr> や <col> の後ろに改行がなければ改行を入れる (add_next_sibling は重いので文字列処理でやる)
      body_str = body_str.gsub(/(<(?:#{ADD_BREAK_LINE_TAGS_REGEXP})>)(?!\r\n)/, "\\1\r\n")
    end
  end
end
