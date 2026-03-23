class Drawer < ApplicationRecord
  belongs_to :profile
  has_many :clothing_items, dependent: :destroy
  has_many :chats, dependent: :destroy
end
