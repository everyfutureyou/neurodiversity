# frozen_string_literal: true

class Components::FormField < Components::Base
  def initialize(label:, for_id:, error: nil)
    @label = label
    @for_id = for_id
    @error = error
  end

  def view_template(&content)
    div(class: "space-y-1") do
      label(for: @for_id, class: "block text-sm font-medium text-(--color-ink)") do
        plain @label
      end
      yield if content
      if @error
        p(class: "text-sm text-(--color-danger)", role: "alert") { plain @error }
      end
    end
  end
end
