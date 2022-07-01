# frozen_string_literal: true

require 'test_helper'

module Api
  class ChecksControllerTest < ActionDispatch::IntegrationTest
    test 'should create a new check' do
      assert_difference(-> { Repository::Check.count }) do
        assert_performed_jobs(1, only: ExecuteRepositoryCheckJob) do
          post(api_checks_url, params: { repository: { id: repositories(:ruby).github_id } })
          assert_response(:ok)

          check = Repository::Check.last
          assert { check.repository == repositories(:ruby) }
          assert { !check.passed? }
          assert { check.finished? }
          assert { check.offences_amount.positive? }
        end
      end
    end

    test 'should not create a new check due to invalid github_id' do
      assert_no_difference(-> { Repository::Check.count }) do
        assert_no_performed_jobs(only: ExecuteRepositoryCheckJob) do
          post(api_checks_url, params: { repository: { id: rand(999_999) } })
          assert_response(:not_found)
        end
      end
    end
  end
end
