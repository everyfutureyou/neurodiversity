class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  generates_token_for :email_confirmation, expires_in: 24.hours do
    confirmed_at
  end

  generates_token_for :password_reset, expires_in: 15.minutes do
    password_salt.last(10)
  end

  def confirmed?
    confirmed_at.present?
  end
end
