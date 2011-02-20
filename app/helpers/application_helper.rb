module ApplicationHelper
  def render_post(p)
    _type = p._type.downcase!
    template = "posts/#{_type}"
    render partial: "posts/post", object: p,
      locals: { sub_template: template }
  end

  def render_form(p)
    _type = p._type
    template = "posts/form_#{_type}"
    render partial: "posts/form", object: p,
    :locals => { sub_template: template }
  end
end
