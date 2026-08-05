class ApplicationController < ActionController::Base
  include Authentication
  include Authorization
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # Phlex views render their own full document — no ERB layout needed.
  layout false

  before_action :set_locale

  helper_method :current_user

  private

  def current_user
    Current.session&.user
  end

  def set_locale
    locale = params[:locale] || session[:locale] || detect_locale_from_header
    I18n.locale = locale if I18n.available_locales.map(&:to_s).include?(locale.to_s)
    session[:locale] = I18n.locale.to_s
  end

  def detect_locale_from_header
    accept = request.env["HTTP_ACCEPT_LANGUAGE"].to_s
    preferred = accept.split(",").first&.split(";")&.first&.split("-")&.first
    preferred&.downcase
  end

  # Inject locale into all generated URLs
  def default_url_options
    { locale: I18n.locale }
  end
end
