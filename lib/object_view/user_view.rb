class UserView
  extend Forwardable
  include ObjectView

  def initialize(user, extra = {})
    @user = user
    @extra = extra
  end

  expose :@user, :name

  def url
    @primary_blog ||= @user.primary_blog
    @extra[:url_template] % @primary_blog.uri
  end

  { 180 => :large,
    60 => :medium,
    24 => :small, }.each do |k, v|
    define_method("avatar_#{k}") do
      @user.primary_blog.icon.url_for(v)
    end
  end
end
