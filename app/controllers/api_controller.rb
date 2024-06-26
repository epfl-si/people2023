# frozen_string_literal: true

# Base class for API controllers in this app
class APIController < ApplicationController
  before_action do
    authenticate!
  end
end
