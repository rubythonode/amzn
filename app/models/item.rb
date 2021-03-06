class Item < ActiveRecord::Base
  self.per_page = 20

  has_many :line_items
  has_many :users, :through => :line_items
  belongs_to :search_node

  validates :title, presence: true
  validates :image_url, presence: true
  validates :url, presence: true
  validates :price, presence: true

  scope :unrated_by, lambda { |user|
    where("not exists (select id from line_items where line_items.item_id = items.id AND line_items.user_id = ?)", user.id)
  }

  scope :liked_by, lambda { |user|
    joins("left outer join line_items as i on items.id = i.item_id")
    .where("i.liked = ?", true)
    .where("i.user_id = ?", user.id)
  }

  scope :disliked_by, lambda { |user|
    joins("left outer join line_items as i on items.id = i.item_id")
    .where("i.liked = false")
    .where("i.user_id = ?", user.id)
  }

  scope :category, lambda { |category_id|
    where(category: category_id)
  }

  def is_liked?(user)
    user.line_items.where(item_id: self.id, liked: true).exists?
  end

  def category
    search_node.category
  end

  def parent_category
    search_node.parent_category
  end
end
