# encoding: utf-8

require 'cgi'

module ObjectView
  def self.wrap(obj, extra = {})
    (obj.class.name + "View").constantize.new(obj, extra)
  end

  def self.included(klass)
    klass.extend(ClassMethods)
  end

  def respond_to?(method)
    klass = self.class
    begin
      return true if klass.public_instance_methods(false).include? method
      klass = klass.superclass
    end while klass.name[-4..-1] == 'View'
    false
  end

  module ClassMethods
    def expose_without_escape(prop_name, *fields)
      fields.each do |f|
        define_method(f) do
          prop = instance_variable_get prop_name
          value = prop.send(f)
          value.nil? ? ''.html_safe : value.html_safe
        end
      end
    end

    def expose(prop_name, *fields)
      fields.each do |f|
        define_method(f) do
          prop = instance_variable_get prop_name
          value = prop.send f
          value.nil? ? ''.html_safe : h(value)
        end
      end
    end
  end

  private
  # RAILS
  def h(str)
    str.html_safe? ? str : CGI.escapeHTML(str).html_safe
  end
  # Y U NO EASY TO REUSE
end

class BlogView < Mustache
  include ObjectView

  VALUE_PARSERS = {
    'bool' => lambda { |v|
      case v
      when /1|true|on|yes/i
        true
      when /0|false|off|no/i
        false
      else
        nil
      end
    },
    'color' => lambda {|v| v}
  }

  def self.parse_custom_vars(str)
    result = {'color' => {}, 'font' => {}, 'text' => {}, 'bool' => {}}
    str.split(/\r\n?|\n/).each do |rule|
      pieces = rule.strip.split
      next if pieces.length != 4
      type = pieces[0]
      next if not self::VALUE_PARSERS.has_key? type
      result[type][pieces[1]] = {
        'desc' => pieces[2],
        'value' => self::VALUE_PARSERS[type].call(pieces[3]),
      }
    end
    result
  end

  def escapeHTML(str)
    str.html_safe? ? str : CGI.escapeHTML(str)
  end

  def initialize(blog, extra = {})
    @blog = blog
    @posts = extra[:posts] && extra[:posts].map {|p| ObjectView.wrap(p, extra)}
    @url_template = extra[:url_template]
    @extra = extra
    self.template = blog.template_in_use
  end

  expose :@blog, :title, :custom_css

  def posts
    @posts
  end

  def post_single
    @extra[:post_single]
  end

  def url
    @extra[:base_url]
  end

  def home_url
    @url_template && @url_template % 'www'
  end

  { 180 => :large,
    60 => :medium,
    24 => :small, }.each do |k, v|
    define_method("icon_#{k}") do
      @blog.icon.url_for(v)
    end
  end

  def define
    Proc.new do |str|
      @variables = self.class.parse_custom_vars(str)
      # `method_missing' rocks but we have to fall back to singleton method for now.
      # See: https://github.com/defunkt/mustache/issues#issue/88
      @variables.each do |type, values|
        values.each do |name, hash|
          self.define_singleton_method "#{type}_#{name}", do
            hash['value']
          end
        end
      end
      @variables.update @blog.template_conf if @blog.template_conf.kind_of? Hash
      ''
    end
  end

  def variables
    @variables
  end

  def post_single
    @extra[:post_single]
  end

  # Ad hoc inline template since we'd make this open to template authors
  def pagination
    return if not @extra[:pagination]
    current_page = @extra[:pagination][:page]
    per_page = @extra[:pagination][:per_page]

    prev_page, cur_page_code = if current_page > 1
      [ "<a class='page_left' href='/page/#{current_page - 1}'>&#8592; 过去的</a>",
        "<div class='page_number'>#{current_page}</div>"
      ]
    else
      ['', '']
    end

    next_page = if (!@posts.empty? && @posts.length >= per_page)
      "<a class='page_right' href='/page/#{current_page + 1}' >以前的 &#8594;</a>"
    else
      ''
    end

    <<TPL.html_safe
<div class="page_control">
  #{prev_page}
  #{cur_page_code}
  #{next_page}
</div>
TPL
  end

  def respond_to?(name)
    return true if name.to_s =~ /^(?:color|bool|text|font)_/
    super
  end
end

Dir[Rails.root.join('lib/object_view/*.rb')].each {|f| require f}
