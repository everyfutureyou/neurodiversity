# frozen_string_literal: true

class Components::PwywWidget < Components::Base
  def view_template
    form_with(
      url: membership_path,
      method: :post,
      data: { controller: "pwyw", action: "submit->pwyw#validate" }
    ) do |f|
      div(class: "space-y-6") do
        amount_section(f)
        preset_buttons
        submit_section(f)
      end
    end
  end

  private

  def amount_section(f)
    div(class: "space-y-2") do
      label(
        for: "amount-input",
        class: "block text-sm font-medium text-(--color-ink)"
      ) { t("memberships.widget.amount_label") }

      div(class: "relative") do
        span(class: "absolute inset-y-0 left-3 flex items-center text-(--color-ink-muted) pointer-events-none") { "€" }
        input(
          type: "number",
          id: "amount-input",
          name: "membership[amount_euros]",
          min: "0",
          step: "0.50",
          placeholder: "0",
          class: "block w-full rounded-(--radius-md) border border-(--color-border) pl-7 pr-4 py-2 text-(--color-ink) focus:border-(--color-brand) focus:outline-none focus:ring-1 focus:ring-(--color-brand)",
          data: {
            pwyw_target: "amount",
            action: "input->pwyw#onInput"
          }
        )
      end

      p(
        id: "pwyw-error",
        class: "text-sm text-(--color-danger) hidden",
        role: "alert",
        data: { pwyw_target: "error" }
      ) { t("memberships.widget.amount_error") }

      p(class: "text-xs text-(--color-ink-muted)") { t("memberships.widget.free_note") }
    end
  end

  def preset_buttons
    div(class: "flex flex-wrap gap-2") do
      [ 0, 3, 5, 10 ].each do |euros|
        button(
          type: "button",
          class: "rounded-(--radius-md) border border-(--color-border) px-4 py-2 text-sm hover:bg-(--color-surface) transition-colors",
          data: { action: "click->pwyw#setPreset", pwyw_euros_param: euros.to_s }
        ) do
          euros.zero? ? t("memberships.widget.preset_free") : "€#{euros}"
        end
      end
    end
  end

  def submit_section(f)
    div do
      button(
        type: "submit",
        class: "w-full inline-flex items-center justify-center font-medium rounded-(--radius-md) transition-colors focus:outline-none focus:ring-2 focus:ring-(--color-brand) focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed bg-(--color-brand) hover:bg-(--color-brand-hover) text-white px-4 py-2 text-base",
        data: { pwyw_target: "submit" }
      ) { t("memberships.widget.submit") }
    end
  end
end
