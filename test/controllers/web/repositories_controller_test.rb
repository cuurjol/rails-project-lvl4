# frozen_string_literal: true

require 'test_helper'

module Web
  # rubocop:disable Metrics/ClassLength
  class RepositoriesControllerTest < ActionDispatch::IntegrationTest
    setup do
      sign_in(users(:regular))
    end

    test 'should get a list of repositories' do
      get(repositories_url)
      assert_response(:success)
    end

    test 'failed pundit authorization to get a list of repositories' do
      assert_no_authorization do
        sign_out
        get(repositories_url)
      end
    end

    test 'should get a creating form of repository' do
      get(new_repository_url)
      assert_response(:success)
    end

    test 'failed pundit authorization to view a creating form of repository' do
      assert_no_authorization do
        sign_out
        get(new_repository_url)
      end
    end

    test 'should create a new repository' do
      github_id = rand(999_999)
      params = { repository: { github_id: github_id } }

      assert_difference(-> { Repository.count }) do
        assert_enqueued_jobs(2, only: [UpdateRepositoryInfoJob, CreateGithubWebhookJob]) do
          post(repositories_url, params: params)
          assert_redirected_to(repositories_url)
          assert { Repository.exists?(github_id: github_id) }
        end
      end
    end

    test 'should not create a new repository due to validation errors' do
      assert_no_difference(-> { Repository.count }) do
        assert_no_enqueued_jobs(only: [UpdateRepositoryInfoJob, CreateGithubWebhookJob]) do
          post(repositories_url, params: { repository: { github_id: nil } })
          assert_response(:unprocessable_entity)
        end
      end
    end

    test 'failed pundit authorization to create a new repository' do
      github_id = rand(999_999)
      params = { repository: { github_id: github_id } }

      assert_no_difference(-> { Repository.count }) do
        assert_no_enqueued_jobs(only: [UpdateRepositoryInfoJob, CreateGithubWebhookJob]) do
          assert_no_authorization do
            sign_out
            post(repositories_url, params: params)
          end
        end
      end
    end

    test 'should show a repository' do
      get(repository_url(repositories(:ruby)))
      assert_response(:success)
    end

    test 'failed pundit authorization to view a foreign repository' do
      assert_no_authorization do
        get(repository_url(repositories(:javascript)))
      end
    end

    test 'failed pundit authorization to view a repository for anonymous user' do
      assert_no_authorization do
        sign_out
        get(repository_url(repositories(:ruby)))
      end
    end

    test 'should destroy an existing repository' do
      repository = repositories(:ruby)

      assert_difference(-> { Repository.count }, -1) do
        assert_enqueued_with(job: RemoveGithubWebhookJob, args: [repository.github_id, current_user.id]) do
          delete(repository_url(repository))
          assert_redirected_to(repositories_url)
          assert { !Repository.exists?(github_id: repository.github_id) }
        end
      end
    end

    test 'failed pundit authorization to destroy an existing foreign repository' do
      assert_no_difference(-> { Repository.count }) do
        assert_no_enqueued_jobs(only: RemoveGithubWebhookJob) do
          assert_no_authorization do
            delete(repository_url(repositories(:javascript)))
          end
        end
      end
    end

    test 'failed pundit authorization to destroy an existing repository for anonymous user' do
      assert_no_difference(-> { Repository.count }) do
        assert_no_enqueued_jobs(only: RemoveGithubWebhookJob) do
          assert_no_authorization do
            sign_out
            delete(repository_url(repositories(:ruby)))
          end
        end
      end
    end

    test 'should update an existing repository from Github' do
      github_repo = JSON.parse(load_fixture('files/found_github_repository.json'), symbolize_names: true)
      repository = repositories(:ruby)

      expression_array = [-> { repository.reload.name }, -> { repository.reload.full_name },
                          -> { repository.reload.description }, -> { repository.reload.html_url },
                          -> { repository.reload.github_created_at }, -> { repository.reload.github_updated_at }]

      to_array = [github_repo[:name], github_repo[:full_name], github_repo[:description],
                  github_repo[:html_url], github_repo[:created_at], github_repo[:updated_at]]

      assert_performed_with(job: UpdateRepositoryInfoJob, args: [repository.id]) do
        assert_many_changes(expression_array, to_array: to_array) do
          patch(update_from_github_repository_url(repository))
        end
      end
    end

    test 'failed pundit authorization to update an existing foreign repository' do
      repository = repositories(:javascript)
      expression_array = [-> { repository.reload.name }, -> { repository.reload.full_name },
                          -> { repository.reload.description }, -> { repository.reload.html_url },
                          -> { repository.reload.github_created_at }, -> { repository.reload.github_updated_at }]

      assert_no_performed_jobs(only: UpdateRepositoryInfoJob) do
        assert_no_many_changes(expression_array) do
          assert_no_authorization do
            patch(update_from_github_repository_url(repository))
          end
        end
      end
    end

    test 'failed pundit authorization to update an existing repository for anonymous user' do
      repository = repositories(:ruby)
      expression_array = [-> { repository.reload.name }, -> { repository.reload.full_name },
                          -> { repository.reload.description }, -> { repository.reload.html_url },
                          -> { repository.reload.github_created_at }, -> { repository.reload.github_updated_at }]

      assert_no_performed_jobs(only: UpdateRepositoryInfoJob) do
        assert_no_many_changes(expression_array) do
          assert_no_authorization do
            sign_out
            patch(update_from_github_repository_url(repository))
          end
        end
      end
    end
  end
  # rubocop:enable Metrics/ClassLength
end
