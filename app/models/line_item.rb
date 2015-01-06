class LineItem < ActiveRecord::Base
  belongs_to :user
  belongs_to :item
  
  validates :user_id, :uniqueness => { :scope => :item_id }
  
  def can_destroy?(user)
    unless user.id == self.user.id
      errors.add(:base, "You must own a line_item to destroy it")
      return false
    end
    return true
  end
end
