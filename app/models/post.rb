class Post
  include Mongoid::Document
  include Mongoid::Timestamps
  
  def haml_object_ref
    "post"
  end

  def self.infer_type t
    klass = Object.const_get t.capitalize
    if self.subclasses.include? klass
      klass
    else
      nil
    end
  end
end
