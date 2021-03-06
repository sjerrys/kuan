module PostsHelper
  def render_post(p)
    type = p.type
    if type == "pics"
      type = if p.photos.length != 1
        "pics_multi"
      else
        "pics_single"
      end
    end
    if type == "post"
      type = "text"
      p.content = ""
    end
    template = "posts/#{type}"
    render partial: "posts/post", object: p,
      locals: { sub_template: template, type: type }
  end

  def render_form(p)
    type = p.type
    template = "posts/form_#{type}"
    content_t
    render partial: "posts/form", object: p,
      :locals => { sub_template: template }
  end
  
  def render_form_photo(p)
    render partial: "posts/form_photo", object: p
  end

  def form_t(par)
    if par[:id].nil?
      url = posts_path
      m = :post
    elsif par[:action] == "renew"
      url = recreate_posts_path
      m = :post
    else
      url = post_path par[:id]
      m = :put
    end
    form_tag url, :method => m, :class => "post_form" do
      yield
    end
  end

  def content_t
    default_open = false
    closable = true
    default_rich = true
    if(@post.type == "text")
      default_open = true
      closable = false
    else
      default_open = false
      closable = true
    end

    unless @post.content.nil? || @post.content.empty?
      default_open = true
      default_rich = true
    end

    render partial: "content", object: @post,
      as: :post,
      :locals => {
        :closable => closable,
        :default_open => default_open,
        :default_rich => default_rich
      }
  end
  def target_post_id
    unless session[:post_id].blank?
      @target_post_id = session[:post_id]
      session.delete :post_id
    end
    @target_post_id
  end
end
