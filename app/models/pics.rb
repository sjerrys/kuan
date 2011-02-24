class Pics < Post
  field :content
  embeds_many :photos

  attr_accessible :photos, :content

  def update_attributes(attrs = {})
    photos = attrs.delete :photos
    if photos.is_a? Array
      self.photos.each do |p|
        p.destroy
      end
      new_photos = photos.map do |p|
        p.delete :id
        i = Image.criteria.id(p[:image]).first
        p[:image] = i
        Photo.new(p)
      end

      self.photos = new_photos
      new_photos.each do |p|
        p.save
      end
    end
    super(attrs)
  end

  validates_length_of :photos, :minimum => 1
end
