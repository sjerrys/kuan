# encoding: utf-8

module ObjectView
  require 'nokogiri'
  require 'cgi'

  def self.wrap(obj, extra = {})
    return nil if obj.nil?
    (obj.class.name + "View").constantize.new(obj, extra)
  end

  def self.included(klass)
    klass.extend(ClassMethods)
  end

  def respond_to?(method)
    return true if self.singleton_methods.include? method
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
          value ? value.html_safe : nil
        end
      end
    end

    def expose_by_dict(prop_name, dict)
      dict.each do |k, v|
        define_method(v) do
          prop = instance_variable_get prop_name
          value = prop.send k
          value.nil? ? nil : h(value)
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
    return ''.html_safe if str.nil?
    str.html_safe? ? str : CGI.escapeHTML(str).html_safe
  end
  # Y U NO EASY TO REUSE

  def self.js_tag(name)
    name = name.to_s
    path = "javascripts/#{name}.js"
    "<script type='text/javascript' src='/#{path}?#{timestamp(path)}'></script>"
  end

  def self.timestamp(path)
    file = "public/#{path}"
    File.stat(Rails.root + file).mtime.to_i
  end

  JS_CODE = (Rails.env.production? ? <<PROD : <<DEV).html_safe
    <script type='text/javascript' src='http://www.kuandao.com/assets/common.js?#{timestamp("assets/common.js")}'></script>
PROD
    #{ObjectView.js_tag('mootools-core')}
    #{ObjectView.js_tag('rails')}
    #{ObjectView.js_tag('mootools-more')}
    #{ObjectView.js_tag('application')}
DEV

  def load_js()
    return '' if @extra[:js]
    @extra[:js] = true
    JS_CODE + @extra[:controller].render_to_string(partial: 'shared/analytics')
  end
  public :load_js
end

class BlogView < Mustache
  include ObjectView

  VALUE_PARSERS = {
    'bool' => lambda { |v|
      case v
      when 1
        true
      when /1|true|on|yes/i
        true
      when 0
        false
      when /0|false|off|no/i
        false
      else
        false
      end
    },
    'color' => lambda {|v| v},
    'text' => lambda {|v| v},
    'image' => lambda {|v| v},
  }

  def self.parse_custom_vars(str)
    result = {'color' => {}, 'image' => {}, 'text' => {}, 'bool' => {}}
    str.split(/\r\n?|\n/).each do |rule|
      pieces = rule.strip.split($;, 4)
      type = pieces[0]
      next if pieces.length < 4 && type == 'color'
      next if pieces.length < 3
      next if not self::VALUE_PARSERS.has_key? type
      result[type][pieces[1]] = {
        'desc' => pieces[2],
        'value' => self::VALUE_PARSERS[type].call(pieces[3]),
      }
    end
    result
  end

  def self.extract_variables(blog)
    EXTRACTOR.blog = blog
    EXTRACTOR.template = blog.template_in_use
    EXTRACTOR.render rescue nil
    EXTRACTOR.variables || {
        'color' => {
        },
        'bool' => {
        },
        'text' => {
        },
        'image' => {
        },
      }
  end

  def escapeHTML(str)
    return '' if str.nil?
    str.html_safe? ? str : CGI.escapeHTML(str)
  end

  def initialize(blog, extra = {})
    @blog = blog
    @posts = extra[:posts] && extra[:posts].map {|p| ObjectView.wrap(p, extra)}
    @url_template = extra[:url_template]
    @extra = extra
    if @extra[:post_single]
      @next_post = ObjectView.wrap @extra[:next_post], @extra
      @prev_post = ObjectView.wrap @extra[:prev_post], @extra
    end
    self.template = blog.template_in_use
  end

  expose :@blog, :title
  expose_without_escape :@blog, :desc, :followers_count

  def meta_desc
    h(Nokogiri::HTML.fragment(desc).inner_text)
  end

  def custom_css
    "<style type='text/css'>#{h @blog.custom_css}</style>".html_safe
  end

  attr_reader :posts

  def prev_post_url
    @prev_post.url if @prev_post
  end

  def next_post_url
    @next_post.url if @next_post
  end

  def post_single
    @extra[:post_single]
  end

  def post_index
    ! @extra[:post_single]
  end

  def url
    @url_template && h(@url_template % @blog.uri)
  end

  def home_url
    @url_template && h(@url_template % 'www')
  end

  { 180 => :large,
    60 => :medium,
    128 => :'128',
    96 => :'96',
    64 => :'64',
    48 => :'48',
    40 => :'40',
    30 => :'30',
    16 => :'16',
    24 => :small, }.each do |k, v|
    define_method("icon_#{k}") do
      h(@blog.icon.url_for(v))
    end
  end

  def is_primary
    @blog.primary?
  end

  def followings
    return nil unless has_following
    fetch_followings
    @followings
  end

  def has_following
    return false unless is_primary
    fetch_followings
    !@followings.empty?
  end

  def fetch_followings
    @followings ||= @blog.lord.subs.reduce [] do |result, b|
      result << BlogView.new(b, @extra) unless b.private?
      result
    end
  end
  private :fetch_followings

  def other_pages
    return nil unless has_other_pages
    fetch_other_pages
    @other_pages
  end

  def has_other_pages
    return false unless is_primary
    fetch_other_pages
    !@other_pages.empty?
  end

  def fetch_other_pages
    @other_pages ||= @blog.lord.other_blogs.reduce [] do |result, b|
      result << ObjectView.wrap(b, @extra) unless b.private?
      result
    end
  end
  private :fetch_other_pages

  def posts_count
    @blog.total_post_num
  end

  def define
    Proc.new do |str|
      @variables = self.class.parse_custom_vars(str)

      if @blog.template_conf.kind_of? Hash
        merge_custom_vars(normalize_variables(@blog.template_conf))
      end
      # `method_missing' rocks but we have to fall back to singleton method for now.
      # See: https://github.com/defunkt/mustache/issues#issue/88
      #
      # Update:
      # Okay now a new release (0.99.3) of mustache solved that issue now
      @variables.each do |type, values|
        values.each do |name, hash|
          self.define_singleton_method "#{type}_#{name}", do
            v = hash['value']
            v.blank? ? nil : v
          end
        end
      end
      ''
    end
  end

  def variables
    @variables
  end

  # Ad hoc inline template since we'd make this open to template authors
  def pagination
    p = @extra[:pagination]
    return nil if (!p) || p[:total_pages] == 1
    current_page = p[:page]
    total_pages = p[:total_pages]
    return [
      :current_page => current_page,
      :total_pages => total_pages,
      :prev_page => (current_page > 1 ? "/page/#{current_page - 1}" : nil),
      :next_page => (current_page >= total_pages ? nil : "/page/#{current_page + 1}"),
    ]
  end

  def follow_tag
    widget = @extra[:controller].render_to_string partial: 'blogs/follow_toggle', locals: {blog: @blog}
    (load_js + widget).html_safe
  end

  def apply_tag
    return false unless @blog.applied? @extra[:current_user]
    apply_link = @extra[:controller].editors_new_path
    Proc.new do |str|
      "<a class='btn_apply' href='#{apply_link}' title='申请加入'>#{str}</a>".html_safe
    end
  end

  def control_buttons
    current_user ? <<CODE : <<ANONY_CODE
#{load_js}
<script>document.getElement("head").grab(new Element("link", {
  rel: "stylesheet"
, href: "/stylesheets/control_buttons.css"
})).grab(new Element("link", {
  rel: "stylesheet"
, href: "/stylesheets/k_box.css"
}))
</script>
<div class='commands'>
  <a class='back_to_home' href='#{home_url}'>回我的主页</a>
  #{customize_tag}
  #{follow_tag}
  #{apply_widget}
  #{repost_tag}
  #{delete_tag}
  #{edit_tag}
  #{fave_tag}
</div>
CODE
#{load_js}
ANONY_CODE
  end

  def fave_tag
    return '' unless post_single
    fave_tag = posts.first.fave_tag.call('')
  end

  def delete_tag
    post = @extra[:posts].first
    return '' unless post_single && post.editable_by?(current_user)
    link = controller.post_path(post)
    "<a href='#{link}' class='remove' title='删除' data-widget='rest' data-md='delete'\
      data-doconfirm='确定删除该条帖子吗?' data-callback='redirect'>删除</a>"
  end

  def edit_tag
    post = @extra[:posts].first
    return '' unless post_single && post.editable_by?(current_user)
    edit_link = controller.edit_post_path(post)
    "<a class='edit' href='#{edit_link}' title='编辑'>编辑</a>"
  end

  def repost_tag
    if post_single && current_user
      repost_link = controller.renew_post_path(@extra[:posts].first)
      "<a class='btn_repost' href='#{repost_link}'>转帖</a>"
    else "" end
  end

  def customize_tag
    if !post_single && @blog.customed?(current_user)
      edit_link = controller.edit_blog_path(@blog)
      "<a class='btn_customize' href='#{edit_link}'>自定义</a>"
    else "" end
  end

  def apply_widget
    if !post_single && @blog.applied?(current_user)
      apply_link = controller.editors_new_path
      "<a class='btn_apply' href='#{apply_link}'>申请加入</a>"
    else "" end
  end

  EXTRACTOR = BlogView.new(Blog.new)
  EXTRACTOR.define_singleton_method :respond_to? do |name|
    name == :define
  end
  EXTRACTOR.define_singleton_method :blog= do |b|
    @blog = b
  end

  private

  def current_user
    @extra[:current_user]
  end

  def controller
    @extra[:controller]
  end

  def normalize_variables(conf)
    VALUE_PARSERS.each do |type, parser|
      next unless conf.has_key? type
      conf[type].each do |name, var|
        var['value'] = parser.call(var['value'])
      end
    end
    conf
  end

  def merge_custom_vars(hash)
    VALUE_PARSERS.each_key do |type|
      next unless hash.has_key? type
      var_set = @variables[type]
      new_var_set = hash[type]
      var_set.each do |name, v|
        v['default_value'] = v['value']
        v['value'] = new_var_set[name]['value'] if new_var_set.has_key? name
      end
    end
  end
end

Dir[Rails.root.join('lib/object_view/*.rb')].each {|f| require f}

class String
  def respond_to?(name, *args)
    return false if name == :constantize
    super(name, *args)
  end
end
