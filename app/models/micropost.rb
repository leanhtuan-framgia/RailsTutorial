class Micropost < ApplicationRecord
  belongs_to :user
  mount_uploader :picture, PictureUploader
  validates :user, presence: true
  validates :content, presence: true, length: {maximum: 140}
  validate :picture_size

  scope :order_by_time, -> {order created_at: :desc}
  scope :feeds,
    ->(other_ids, id) {where("user_id IN (?) OR user_id = ?", other_ids, id)}

  private
  def picture_size
    if picture.size > 5.megabytes
      errors.add :picture, "should be less than 5MB"
    end
  end
end