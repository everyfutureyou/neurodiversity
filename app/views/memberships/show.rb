# frozen_string_literal: true

class Views::Memberships::Show < Views::Base
  def initialize(membership:)
    @membership = membership
  end

  def page_title = t("memberships.show.title")

  def page_content
    div(class: "max-w-lg mx-auto py-12 space-y-6") do
      render Components::Heading.new(t("memberships.show.heading"), level: 1)

      div(class: "rounded-(--radius-lg) border border-(--color-border) p-6 space-y-4") do
        status_badge
        amount_row
      end
    end
  end

  private

  def status_badge
    label = t("memberships.status.#{@membership.status}")
    css = @membership.active? ? "bg-green-100 text-green-800" : "bg-gray-100 text-(--color-ink-muted)"
    div(class: "flex items-center gap-2") do
      span(class: "text-sm font-medium text-(--color-ink-muted)") { t("memberships.show.status_label") }
      span(class: "inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-semibold #{css}") { label }
    end
  end

  def amount_row
    return if @membership.free?

    div(class: "flex items-center gap-2") do
      span(class: "text-sm font-medium text-(--color-ink-muted)") { t("memberships.show.amount_label") }
      span(class: "text-(--color-ink)") do
        t("memberships.show.monthly_amount", amount: format("€%.2f", @membership.monthly_amount_euros))
      end
    end
  end
end
