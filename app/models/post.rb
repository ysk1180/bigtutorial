class Post < ApplicationRecord
  validates :content, presence: true
  validates :content, length: { maximum: 90 }
end
