# frozen_string_literal: true

module Dev
  class ComponentsController < ApplicationController
    allow_unauthenticated_access
    layout false

    def index
      render Views::Dev::Components.new
    end
  end
end
