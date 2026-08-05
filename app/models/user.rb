class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :posts, foreign_key: :author_id, dependent: :destroy
  has_one :membership, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :messages, dependent: :destroy

  enum :role, { guest: 0, member: 1, admin: 2 }, validate: true

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  normalizes :locale, with: ->(l) { I18n.available_locales.map(&:to_s).include?(l.to_s) ? l.to_s : I18n.default_locale.to_s }

  def at_least_member? = member? || admin?

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
