# frozen_string_literal: true

class HomeController < ApplicationController
  allow_unauthenticated_access

  def index
    render Views::Home::Index.new
  end

  def redirect_to_locale
    locale = detect_locale_from_header || I18n.default_locale
    locale = I18n.available_locales.map(&:to_s).include?(locale.to_s) ? locale : I18n.default_locale
    redirect_to "/#{locale}", status: :moved_permanently
  end
end
