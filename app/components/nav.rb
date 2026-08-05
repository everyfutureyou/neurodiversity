# frozen_string_literal: true

class Components::Nav < Components::Base
  def view_template
    nav(class: "border-b border-(--color-border) bg-(--color-surface)") do
      div(class: "container mx-auto px-4 py-3 flex items-center justify-between") do
        a(href: root_path, class: "text-(--color-brand) font-semibold text-lg") do
          t("app.name")
        end
        div(class: "flex items-center gap-4") do
          render Components::LocaleSwitcher.new
          if current_user
            if current_user.admin?
              link_to t("nav.admin"), admin_posts_path, class: nav_link_classes
              link_to t("nav.messages"), admin_messages_path, class: nav_link_classes
            end
            link_to t("nav.contact"), new_message_path, class: nav_link_classes
            link_to t("nav.account"), "#", class: nav_link_classes
            link_to t("nav.sign_out"), session_path, data: { turbo_method: :delete },
                    class: nav_link_classes
          else
            link_to t("nav.sign_in"), new_session_path, class: nav_link_classes
            link_to t("nav.register"), new_registration_path,
                    class: "#{nav_link_classes} bg-(--color-brand) text-white rounded-(--radius-md) px-3 py-1"
          end
        end
      end
    end
  end

  private

  def nav_link_classes
    "text-sm text-(--color-ink-muted) hover:text-(--color-ink) transition-colors"
  end
end
