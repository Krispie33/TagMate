class ClothingItem < ApplicationRecord
  belongs_to :drawer

  has_one_attached :tag_image
  has_one_attached :item_image

  validates :tag_image, presence: true
  validates :item_image, presence: true
end
