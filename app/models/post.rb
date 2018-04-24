class Post < ApplicationRecord
  include PostsHelper
  mount_uploader :image, ImageUploader
  validates :title, :content, presence: true
  belongs_to :user

  has_many :folders, dependent: :destroy
  has_many :categories, through: :folders

  has_many :comments, dependent: :destroy

  has_many :views, dependent: :destroy
  has_many :viewed_users, through: :views, source: :user

  has_many :collections, dependent: :destroy
  has_many :collected_users, through: :collections, source: :user

   POST_PRIVACY = [
    ['All', :all],
    ['Friend', :friend],
    ['Myself', :myself]
  ]
end
