# frozen_string_literal: true

class Membership < ApplicationRecord
  belongs_to :user

  enum :status, { inactive: 0, active: 1, past_due: 2, canceled: 3 }, validate: true

  validates :amount_cents, numericality: { greater_than_or_equal_to: 0 }

  scope :active, -> { where(status: :active) }

  def free? = amount_cents.zero?
  def monthly_amount_euros = amount_cents / 100.0
end
