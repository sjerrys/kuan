# -*- coding: utf-8 -*-
class UsersController < ApplicationController
  before_filter :signin_auth, :only => [:show, :edit, :update]

  def new
    @user = User.new
  end

  def create
    @user = User.new params[:user]
    return render 'new' if !@user.save

    #create primary blog
    blog = Blog.new(:title => @user.name,
                    :uri => @user.uri_by_name)
    blog.primary = true
    blog.save
    @user.follow Following.new(:blog => blog, :auth => "lord")

    sign_in @user
    flash[:success] = "欢迎注册"
    redirect_to home_path
  end

  def show
  end

  def edit
  end

  def update
    if @user.update_attributes params[:user]
      flash[:success] = "账户信息更新成功"
      redirect_to home_path
    else
      render 'edit'
    end
  end

end
