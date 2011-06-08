# -*- coding: utf-8 -*-
class CommentsController < ApplicationController
  before_filter :signin_auth
  layout proc{ |c| c.request.xhr? ? false : "application" }

  def index
    @post = Post.find(params[:post_id])
    notice = current_user.comments_notices.get_by_post(@post).first
    notice.read! unless notice.nil?
  end

  def create
    @post = Post.find(params[:post_id])
    redirect_to home_path if @post.nil?
    @comment = Comment.new(:content => params[:content], :author_id => current_user.id)
    if @comment.valid?
      @post.comments << @comment
      @post.notify_watchers @comment
      render "comments/index"
    else
      render "comments/index"
    end
  end

  def destroy
    @post = Post.find(params[:post_id])
    @comment = @post.comments.find(params[:id])
    if(@comment.nil? || !(@comment.manageable_by? @user))
      respond_to do |format|
        format.json { render :json => {status: "error", message: "删除失败" } }
      end
      return
    end
    @comment.destroy
    respond_to do |format|
      format.json { render :json => {status: "success", message: "删除成功" } }
    end
  end
end
