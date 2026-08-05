# frozen_string_literal: true

class Views::Admin::Base < Views::Base
  private

  def th_classes
    "px-4 py-3 text-left text-xs font-medium text-(--color-ink-muted) uppercase tracking-wider"
  end

  def td_classes
    "px-4 py-3"
  end
end
