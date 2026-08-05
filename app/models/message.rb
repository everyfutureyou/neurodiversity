# frozen_string_literal: true

class Message < ApplicationRecord
  belongs_to :user

  validates :subject, presence: true
  validates :body, presence: true

  scope :newest_first, -> { order(created_at: :desc) }
end
