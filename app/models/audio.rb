# -*- coding: utf-8 -*-
class Audio < Post
  include Mongoid::Document
  field :song_id
  field :album_art
  field :album_name
  field :song_name
  field :artist_name
  field :content

  attr_accessible :song_id, :album_art, :content, :song_name, :artist_name,
    :album_name

  before_validation :sanitize_content
  validates_presence_of :song_id, :message => '选首歌先?'

  def flash_url
    "http://www.xiami.com/widget/0_#{song_id}/singlePlayer.swf"
  end

  def flash_url_autoplay
    "http://img.xiami.com/widget/0_#{song_id}_/singlePlayer.swf"
  end

  def album_art_orig
    self.album_art.sub '_1.jpg', '.jpg'
  end
end
