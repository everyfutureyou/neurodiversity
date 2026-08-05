# frozen_string_literal: true

class Comment < ApplicationRecord
  belongs_to :post
  belongs_to :user
  belongs_to :parent, class_name: "Comment", optional: true
  has_many :replies, class_name: "Comment", foreign_key: :parent_id, dependent: :destroy, inverse_of: :parent

  validates :body, presence: true
  validate :parent_belongs_to_same_post, if: -> { parent_id.present? }

  scope :for_post, ->(post) { where(post: post) }
  scope :roots, -> { where(parent_id: nil) }
  scope :oldest_first, -> { order(created_at: :asc) }

  def root? = parent_id.nil?

  private

  def parent_belongs_to_same_post
    return unless parent
    errors.add(:parent_id, :invalid) unless parent.post_id == post_id
  end
end
