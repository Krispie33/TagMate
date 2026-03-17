class Drawer < ApplicationRecord
  belongs_to :profile
  has_many :cloths, dependent: :destroy
  has_many :chats, dependent: :destroy
end
