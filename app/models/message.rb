class Message
  include Mongoid::Document
  field :type
  field :unread, :type => Boolean, :default => true
  field :done, :type => Boolean, :default => false
  field :ignored, :type => Boolean, :default => false
  field :sender_id
  referenced_in :blog
  embedded_in :user, :inverse_of => :messages
  scope :unreads, where(:unread => true)
  validates :type, :inclusion => {:in => %w[join]}

  def sender=(sender)
    self.sender_id = sender.id
  end

  def sender
    User.find(sender_id) unless sender_id.nil?
  end

  def read!
    update_attributes :unread => false 
  end

  def ignore!
    update_attributes :ignored => true
  end

  def doing!
    return if done?
    send type
    update_attributes :done => true
  end

  def join
    sender.follow! blog, "member" if blog.applied?(sender) and blog.customed?(user)
  end
end