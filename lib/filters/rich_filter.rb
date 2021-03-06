require 'nokogiri'
require 'uri'

class RichFilter
  TAG_WHITE_LIST = %w{pre code tt a p s i b div span table thead tbody tfoot tr th td h1 h2 h3 h4 h5 h6 img strong em br hr ul ol li blockquote cite sub sup ins video audio object embed section footer header nav article small hgroup font strike dd dt dl center}
  ATTR_WHITE_LIST = %w{href title src style width height alt wmode type color align class id}
  MALICIOUS_CSS = Regexp.union(/e\s*x\s*p\s*r\s*e\s*s\s*s\s*i\s*o\s*n/i, /u\s*r\s*l/i)
  LEGAL_URL = lambda { |url|
    url =~ %r{^https?://}i ?  url : ""
  }
  SPECIAL_ATTR = {
    'style' => lambda { |css|
      rules = css.split /\s*;\s*/
      rules.reject! {|r| r.match MALICIOUS_CSS}
      rules.join('; ')
    },
    'src' => LEGAL_URL,
    'href' => LEGAL_URL,
  }
  LEGAL_URL_SCHEMES = %w[http https ftp mailto ed2k thunder mms telnet]
  N = Nokogiri::XML::Node

  class << self
    def tags(content)
      return nil if content.blank?
      raise "Expecting a string" unless content.kind_of? String
      tree = Nokogiri::HTML.fragment(content)
      tree.traverse do |n|
        case n.type
        when N::TEXT_NODE
          next if has_parent?(n, 'a')
          n.replace Nokogiri::HTML.fragment(auto_link!(n.to_html))
        when N::ELEMENT_NODE
          n.unlink unless TAG_WHITE_LIST.include? n.name
          n.each do |k, v|
            n.delete k unless ATTR_WHITE_LIST.include? k
            n[k] = SPECIAL_ATTR[k].call v if SPECIAL_ATTR.has_key? k
          end
        end
      end
      tree.to_html
    end

    def auto_link!(str)
      str_with_links = str.dup
      URI.extract(str, LEGAL_URL_SCHEMES) do |link|
        str_with_links[link] = %(<a href="#{link}" target="_blank">#{link}</a>)
      end 
      str_with_links
    end


    def has_parent?(node, parent_name)
      while node = node.parent
        return true if node.name == parent_name
      end
      false
    end
  end
end
