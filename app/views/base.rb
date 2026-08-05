# frozen_string_literal: true

class Views::Base < Components::Base
  # Subclasses may override to set the browser tab title.
  def page_title = t("app.name")

  # Subclasses may override to customise meta tags (description, og, json_ld).
  def page_meta = { description: t("meta.description", default: "") }

  # Entry point for all page views — wraps content in ApplicationLayout.
  # Subclasses override #page_content for their body content.
  def view_template
    render Components::ApplicationLayout.new(title: page_title, meta: page_meta) do
      page_content
    end
  end

  # Override in subclasses instead of #view_template.
  def page_content; end

  def cache_store = Rails.cache
end
