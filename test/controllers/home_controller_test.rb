# frozen_string_literal: true

require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "root redirects to detected locale" do
    get "/"
    assert_response :moved_permanently
    assert_match %r{/(en|de)}, response.location
  end

  test "locale root renders the landing page" do
    get "/en"
    assert_response :success
  end

  test "hero section renders headline" do
    get "/en"
    assert_includes response.body, I18n.t("home.headline", locale: :en)
  end

  test "hero section renders subheading" do
    get "/en"
    assert_includes response.body, I18n.t("home.subheading", locale: :en)
  end

  test "page includes accessible landmark regions" do
    get "/en"
    assert_match /<section/, response.body
    assert_match /aria-labelledby/, response.body
  end

  test "PWYW membership widget is present for a guest" do
    get "/en"
    assert_includes response.body, "membership[amount_euros]"
  end

  test "PWYW widget is absent for an active member" do
    user = users(:one)
    user.update!(role: :member)
    user.create_membership!(status: :active, amount_cents: 0) unless user.membership
    sign_in_as(user)

    get "/en"
    assert_not_includes response.body, "membership[amount_euros]"
  end

  test "German locale renders German headline" do
    get "/de"
    assert_response :success
    assert_includes response.body, I18n.t("home.headline", locale: :de)
  end

  test "features section renders topic headings" do
    get "/en"
    assert_includes response.body, I18n.t("home.features.adhd.title", locale: :en)
    assert_includes response.body, I18n.t("home.features.autism.title", locale: :en)
    assert_includes response.body, I18n.t("home.features.dyslexia.title", locale: :en)
  end

  test "membership section heading is present" do
    get "/en"
    assert_includes response.body, I18n.t("home.membership_cta.heading", locale: :en)
  end
end
