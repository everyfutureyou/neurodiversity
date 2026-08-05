# frozen_string_literal: true

class Views::Dev::Components < Views::Base
  def page_title = "Component Gallery"

  def page_content
    div(class: "max-w-4xl mx-auto space-y-12") do
      render Components::Heading.new("Component Gallery", level: 1)

      section_block("Headings") do
        (1..4).each do |level|
          render Components::Heading.new("Heading Level #{level}", level:)
        end
      end

      section_block("Buttons") do
        div(class: "flex flex-wrap gap-3") do
          %i[primary secondary danger ghost].each do |variant|
            render Components::Button.new(variant.to_s.capitalize, variant:)
          end
        end
        div(class: "flex flex-wrap gap-3 mt-3") do
          %i[sm md lg].each do |size|
            render Components::Button.new("Size #{size}", size:)
          end
        end
      end

      section_block("Locale Switcher") do
        render Components::LocaleSwitcher.new
      end
    end
  end

  private

  def section_block(title, &content)
    section(class: "border border-(--color-border) rounded-(--radius-lg) p-6 space-y-4") do
      render Components::Heading.new(title, level: 3)
      yield
    end
  end
end
