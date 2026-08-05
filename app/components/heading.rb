# frozen_string_literal: true

class Components::Heading < Components::Base
  LEVELS = {
    1 => { tag: :h1, classes: "text-4xl font-bold tracking-tight" },
    2 => { tag: :h2, classes: "text-3xl font-semibold tracking-tight" },
    3 => { tag: :h3, classes: "text-2xl font-semibold" },
    4 => { tag: :h4, classes: "text-xl font-medium" },
    5 => { tag: :h5, classes: "text-lg font-medium" },
    6 => { tag: :h6, classes: "text-base font-medium" }
  }.freeze

  def initialize(text = nil, level: 2, classes: nil)
    @text = text
    @level = level
    @extra_classes = classes
  end

  def view_template(&content)
    config = LEVELS.fetch(@level)
    combined = [ @extra_classes, config[:classes], "text-(--color-ink)" ].compact.join(" ")

    send(config[:tag], class: combined) do
      content ? yield : plain(@text)
    end
  end
end
