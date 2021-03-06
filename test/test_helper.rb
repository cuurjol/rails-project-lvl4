# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'webmock/minitest'
require 'support/file_loader_helper'
OmniAuth.config.test_mode = true

module ActiveSupport
  class TestCase
    include FileLoaderHelper

    setup do
      queue_adapter.perform_enqueued_jobs = true
      queue_adapter.perform_enqueued_at_jobs = true
    end

    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
    ActiveRecord::FixtureSet.context_class.include(FileLoaderHelper)
  end
end

module ActionDispatch
  class IntegrationTest
    def sign_in(user)
      auth_hash = { credentials: { token: user.token }, info: { email: user.email, nickname: user.nickname } }
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash::InfoHash.new(auth_hash)

      get(callback_auth_url('github'))
    end

    def sign_out
      delete(sign_out_url)
    end

    def signed_in?
      session[:user_id].present? && current_user.present?
    end

    def current_user
      @current_user ||= User.find_by(id: session[:user_id])
    end
  end
end
