# frozen_string_literal: true

require 'test_helper'

module Web
  class AuthControllerTest < ActionDispatch::IntegrationTest
    test 'should check Github auth' do
      post(auth_request_path('github'))
      assert_redirected_to(callback_auth_url('github'))
    end

    test 'should create and authenticate a new user via Github' do
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash::InfoHash.new(Faker::Omniauth.github)

      assert_difference(-> { User.count }) do
        get(callback_auth_url('github'))
        assert_redirected_to(root_url)
        assert(signed_in?)
      end
    end

    test 'should not create and authenticate a new user via Github due to validation errors' do
      auth_hash = { credentials: { token: '' }, info: { email: '', nickname: '' } }
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash::InfoHash.new(auth_hash)

      assert_no_difference(-> { User.count }) do
        get(callback_auth_url('github'))
        assert_redirected_to(root_url)
        assert_not(signed_in?)
      end
    end

    test 'should destroy a session for authorized user' do
      sign_in(users(:regular))
      delete(sign_out_url)
      assert_redirected_to(root_url)
      assert_not(signed_in?)
    end

    test 'should not destroy an invalid session' do
      delete(sign_out_url)
      assert_redirected_to(root_url)
    end
  end
end
