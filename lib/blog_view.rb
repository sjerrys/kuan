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
    def expose(prop_name, *fields)
      fields.each do |f|
        define_method(f) do
          prop = instance_variable_get prop_name
          prop.send(f).html_safe
        end
      end
    end

    def expose_with_h(prop_name, *fields)
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

  expose_with_h :@blog, :title

  def posts
    @posts
  end

  def post_single
    @extra[:post_single]
  end

  def load_comments
    <<EOF
  <iframe border=0 width='594px' scrolling=NO style="overflow-x: hidden; overflow-y: scroll" src="#{@posts[0].url_for_comments}"></iframe>
EOF
  end

  def url
    @extra[:base_url]
  end

  def home_url
    @url_template % 'www'
  end

  def icon_180
    @blog.icon.url_for(:large)
  end

  def icon_60
    @blog.icon.url_for(:medium)
  end

  def icon_24
    @blog.icon.url_for(:small)
  end
end

Dir[Rails.root.join('lib/object_view/*.rb')].each {|f| require f}
