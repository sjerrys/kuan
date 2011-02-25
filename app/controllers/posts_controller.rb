# encoding: utf-8

class PostsController < ApplicationController
  before_filter :signin_auth

  def new
    @type = params[:type] || Post.default_type
    @post = Post.infer_type(@type).new
    @post.type = @type
    @target_blogs = @user.blogs
  end

  def create
    @post = Post.infer_type(params[:type]).new(params)
    respond_to do |format|
      if @post.save
        format.js
      else
        render :action => 'new'
      end
    end
  end

  def edit
    @post = Post.find(params[:id])
    if not @post.editable_by? @user
      render :status => :forbidden, :text => "放开那帖子"
    end
  end

  def update
    @post = Post.find(params[:id])
    respond_to do |format|
      if @post.update_attributes(params)
        format.js
      else
        render :action => 'edit'
      end
    end
  end

  def destroy
    @post = Post.find(params[:id])
    @post.destroy
    respond_to do |format|
      format.js
    end
  end

end
