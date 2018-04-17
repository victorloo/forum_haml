class Post < ApplicationRecord
  mount_uploader :image, ImageUploader
  validates :title, :content, presence: true
  belongs_to :user

  has_many :folders, dependent: :destroy
  has_many :categories, through: :folders
end
