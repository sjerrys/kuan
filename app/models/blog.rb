# -*- coding: utf-8 -*-
class Blog
  include Mongoid::Document
  include Mongoid::Timestamps
  field :uri
  field :title
  referenced_in :icon, :class_name => 'image'
  field :primary, :type => Boolean, :default => false
  references_many :followings
  references_many :posts

  attr_accessible :uri, :title, :icon
  
  validates_presence_of :title, 
    :message => "请输入用户名"
  validates_length_of :title,
    :minimum => 1,
    :maximum => 40,
    :too_short => "最少%{count}个字",
    :too_long => "最多%{count}个字"
  
  validates_presence_of :uri,
    :message => "请输入链接"
  validates_format_of :uri,
    :with => /^[0-9a-z-]{4,30}$/i,
    :message => "链接格式不正确"
  validates_uniqueness_of :uri,
    :case_sensitive => false,
    :message => "此链接已被使用"

  def followed?(user)
    !user.followings.where(:blog_id => _id, :auth => "follower").empty?
  end

  def edited?(user)
    !user.followings.where(:blog_id => _id).excludes(:auth => "follower").empty?
  end

  def customed?(user)
    !user.followings.where(:blog_id => _id).any_in(:auth => ["founder", "lord"]).empty?
  end

  def followers_count
    User.where("followings.blog_id" => _id,
               "followings.auth" => "follower").count
  end

  def followers
    User.where("followings.blog_id" => _id,
               "followings.auth" => "follower").
      desc("followings.created_at").limit(100)
  end
end
