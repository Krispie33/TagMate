class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :clothing_items
  has_many :drawers

  validate :password_complexity, if: -> { password.present? }

  private

  def password_complexity
    rules = {
      'one uppercase' => /[A-Z]/,
      'one number' => /\d/,
      'one special character' => /[!@#$%^&*]/
    }

    rules.each do |requirement, regex|
      next if password.match?(regex)

      errors.add(:password, "must include at least #{requirement}")
    end
  end
  has_many :profiles
  has_many :chats
end
