# -*- coding: utf-8 -*-
require 'uri'
require 'open-uri'
require 'nokogiri'

class Feed
  include Mongoid::Document
  include Mongoid::Timestamps

  field :title
  field :uri
  field :imported_count, :type => Integer, :default => 0
  index :imported_count

  validates_presence_of :uri
  validates_uniqueness_of :uri

  validate :check_uri, :if => :new_record?

  private

  def check_uri
    self.uri = "http://" + uri unless uri =~ /^http:\/\//
    http = URI.parse uri
    begin
      http.open do |io|
        doc = Nokogiri::HTML io, nil, io.charset
        self.title = doc.xpath('//title').first.content 
      end
    rescue Exception => e
      return self.errors.add :uri, "无法识别此地址"
    end
  end

end
