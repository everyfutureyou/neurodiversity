module SessionTestHelper
  def sign_in_as(user)
    Current.session = user.sessions.create!

    ActionDispatch::TestRequest.create.cookie_jar.tap do |cookie_jar|
      cookie_jar.signed[:session_id] = Current.session.id
      cookies["session_id"] = cookie_jar[:session_id]
    end
  end

  def sign_out
    Current.session&.destroy!
    cookies.delete("session_id")
  end
end

# Force English locale for all integration tests and inject locale into URL helpers
LocaleUrlOptions = Module.new do
  def url_options
    super.merge(locale: :en)
  end
end

ActiveSupport.on_load(:action_dispatch_integration_test) do
  include SessionTestHelper
  prepend LocaleUrlOptions

  # Force English locale before each test so assertions match en.yml strings
  setup { I18n.locale = :en }
  teardown { I18n.locale = I18n.default_locale }
end
