# frozen_string_literal: true

class Components::Base < Phlex::HTML
  include Phlex::Rails::Helpers::Routes
  include Phlex::Rails::Helpers::Translate
  include Phlex::Rails::Helpers::ContentFor
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::FormWith
  include Phlex::Rails::Helpers::ButtonTo

  # Expose current_user from the controller context
  def current_user = view_context.current_user

  if Rails.env.development?
    def before_template
      comment { "Before #{self.class.name}" }
      super
    end
  end
end
