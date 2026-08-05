# frozen_string_literal: true

class Post < ApplicationRecord
  belongs_to :author, class_name: "User"
  has_many :comments, dependent: :destroy

  delegate :email_address, to: :author, prefix: true

  validates :slug, presence: true, uniqueness: true,
                   format: { with: /\A[a-z0-9-]+\z/, message: "only allows lowercase letters, numbers, and hyphens" }

  scope :published, -> { where.not(published_at: nil).where(published_at: ..Time.current) }
  scope :newest_first, -> { order(published_at: :desc) }
  scope :in_locale, ->(locale) { where("title ? :locale", locale: locale.to_s) }

  def to_param = slug

  def published?
    published_at.present? && published_at <= Time.current
  end

  def publish!
    update!(published_at: Time.current)
  end

  def unpublish!
    update!(published_at: nil)
  end

  def localized_title(locale = I18n.locale)
    localized_field(title, locale)
  end

  def localized_body(locale = I18n.locale)
    localized_field(body, locale)
  end

  private

  def localized_field(field, locale)
    field[locale.to_s] || ""
  end
end
