class Category
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, :type => String
  field :new, :type => Boolean, :default => false
  field :top, :type => Boolean, :default => false
  field :order, :type => Integer, :default => 0
  embeds_many :category_subs

  scope :top_categories, where(:top => true).desc(:order)

  class << self
    def find_by_name!(name)
      where(:name => name).first
    end
  end

  def top_blog
    category_subs.where(top: true).first
  end
end
