# -*- coding: utf-8 -*-
class UsersController < ApplicationController
  before_filter :signin_auth, :only => [:show, :edit, :update, :followings]
  before_filter :signup_auth, :only => [:new, :create]

  def new
    @user = User.new
    render :layout => "user"
  end

  def create
    @user = User.new params[:user]
    return (render 'new', :layout => "user") if !@user.save

    @user.create_primary_blog!
    @inv_user.blogs.each {|b| @user.follow! b}

    sign_in @user
    flash[:success] = "欢迎注册"
    redirect_to home_path
  end

  #param :uri: 显示指定uri的blog的信息和帖子列表，否则使用默认页面
  def show
    @blog = @user.primary_blog
    @blogs = @user.blogs
    pagination = {
      :page => params[:page] || 1,
      :per_page => 10,
    }
    @at_dashboard = params[:uri].blank?
    if !@at_dashboard
      param_blog = Blog.where(:uri => params[:uri]).first
      @blog = @user.blogs.include?(param_blog) ? param_blog : @blog
      cond = {:blog_id => @blog.id}
    else
      sub_id_list = @user.all_blogs.reduce [], do |list, blog|
        if blog.open_to?(@user) then list << blog.id else list end
      end
      cond = {:blog_id.in => sub_id_list}
    end
    @posts = Post.desc(:created_at).where(cond).paginate(pagination)
  end

  def edit
    render :layout => "account"
  end

  def update
    if(params[:user][:password].blank? && params[:user][:password_confirmation].blank?)
       params[:user].delete(:password)
       params[:user].delete(:password_confirmation)
    end

    if @user.update_attributes params[:user]
      flash[:success] = "帐户信息更新成功"
      redirect_to home_path
    else
      render 'edit', :layout => "account"
    end
  end

  def followings
    @blogs = @user.subs
    render :layout => "blogs"
  end

  private

  def signup_auth
    return render 'invalid_invitation' if params[:code].blank?
    @inv_user = User.find_by_code params[:code]
    return render 'invalid_invitation' if @inv_user.nil?
  end
end
