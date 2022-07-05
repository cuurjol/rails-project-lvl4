# frozen_string_literal: true

require 'test_helper'

module Web
  module Repositories
    class ChecksControllerTest < ActionDispatch::IntegrationTest
      setup do
        @javascript_repository = repositories(:javascript)
        @ruby_repository = repositories(:ruby)
        sign_in(users(:regular))
      end

      test 'should create a new check' do
        assert_difference(-> { Repository::Check.count }) do
          assert_performed_jobs(1, only: ExecuteRepositoryCheckJob) do
            post(repository_checks_url(@ruby_repository))
            assert_redirected_to(repository_url(@ruby_repository))

            check = Repository::Check.last
            assert { check.repository == @ruby_repository }
            assert { !check.passed? }
            assert { check.finished? }
            assert { check.offense_files.present? }
          end
        end
      end

      test 'failed pundit authorization to create a new check' do
        assert_no_difference(-> { Repository::Check.count }) do
          assert_no_performed_jobs(only: ExecuteRepositoryCheckJob) do
            assert_no_authorization do
              sign_out
              post(repository_checks_url(@ruby_repository))
            end
          end
        end
      end

      test 'should show a check' do
        get(repository_check_url(@ruby_repository, @ruby_repository.checks.last))
        assert_response(:success)
      end

      test 'failed pundit authorization to view a foreign check' do
        assert_no_authorization do
          get(repository_check_url(@javascript_repository, @javascript_repository.checks.last))
        end
      end

      test 'failed pundit authorization to view a check for anonymous user' do
        assert_no_authorization do
          sign_out
          get(repository_check_url(@ruby_repository, @ruby_repository.checks.last))
        end
      end
    end
  end
end
