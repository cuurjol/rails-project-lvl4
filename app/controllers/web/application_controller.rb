# frozen_string_literal: true

module Web
  class ApplicationController < ::ApplicationController
    include Authorization
    include Pagy::Backend
    include Pundit::Authorization

    helper_method(:user_signed_in?, :current_user)

    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

    private

    def user_not_authorized(exception)
      policy_name = exception.policy.class.to_s.underscore
      flash[:alert] = t("#{policy_name}.#{exception.query}", scope: :pundit, default: :default)
      redirect_back(fallback_location: root_path)
    end
  end
end
