# frozen_string_literal: true

module Web
  class ApplicationController < ::ApplicationController
    include Authorization
    helper_method(:user_signed_in?, :current_user)
  end
end
