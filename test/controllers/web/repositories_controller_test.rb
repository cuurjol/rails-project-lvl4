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
      sign_out
      get(repositories_url)
      assert_redirected_to(root_url)
    end

    test 'should get a creating form of repository' do
      get(new_repository_url)
      assert_response(:success)
    end

    test 'failed pundit authorization to view a creating form of repository' do
      sign_out
      get(new_repository_url)
      assert_redirected_to(root_url)
    end

    test 'should create a new repository' do
      github_id = rand(999_999)
      repo_attributes = %w[name full_name description language html_url github_created_at github_updated_at clone_url]
      github_attributes = %w[name full_name description language html_url created_at updated_at clone_url]
      github_repository = JSON.parse(load_fixture('files/found_github_repository.json'))
      params = { repository: { github_id: github_id } }

      assert_difference(-> { Repository.count }) do
        assert_performed_jobs(2, only: [UpdateRepositoryInfoJob, CreateGithubWebhookJob]) do
          post(repositories_url, params: params)
          assert_redirected_to(repositories_url)
          assert { Repository.exists?(github_id: github_id) }

          repository = Repository.find_by(github_id: github_id)
          repo_attributes.zip(github_attributes).each do |repo_attr, github_attr|
            if repo_attr == 'language'
              assert { repository[repo_attr].capitalize == github_repository[github_attr] }
            else
              assert { repository[repo_attr] == github_repository[github_attr] }
            end
          end
        end
      end
    end

    test 'should not create a new repository due to validation errors' do
      assert_no_difference(-> { Repository.count }) do
        assert_no_performed_jobs(only: [UpdateRepositoryInfoJob, CreateGithubWebhookJob]) do
          post(repositories_url, params: { repository: { github_id: nil } })
          assert_redirected_to(new_repository_url)
          assert { !Repository.exists?(github_id: nil) }
        end
      end
    end

    test 'failed pundit authorization to create a new repository' do
      github_id = rand(999_999)
      params = { repository: { github_id: github_id } }

      assert_no_difference(-> { Repository.count }) do
        assert_no_performed_jobs(only: [UpdateRepositoryInfoJob, CreateGithubWebhookJob]) do
          sign_out
          post(repositories_url, params: params)
          assert_redirected_to(root_url)
          assert { !Repository.exists?(github_id: github_id) }
        end
      end
    end

    test 'should show a repository' do
      get(repository_url(repositories(:ruby)))
      assert_response(:success)
    end

    test 'failed pundit authorization to view a foreign repository' do
      get(repository_url(repositories(:javascript)))
      assert_redirected_to(root_url)
    end

    test 'failed pundit authorization to view a repository for anonymous user' do
      sign_out
      get(repository_url(repositories(:ruby)))
      assert_redirected_to(root_url)
    end

    test 'should destroy an existing repository' do
      repository = repositories(:ruby)

      assert_difference(-> { Repository.count }, -1) do
        assert_performed_with(job: RemoveGithubWebhookJob, args: [repository.github_id, current_user.id]) do
          delete(repository_url(repository))
          assert_redirected_to(repositories_url)
          assert { !Repository.exists?(github_id: repository.github_id) }
        end
      end
    end

    test 'failed pundit authorization to destroy an existing foreign repository' do
      assert_no_difference(-> { Repository.count }) do
        assert_no_performed_jobs(only: RemoveGithubWebhookJob) do
          delete(repository_url(repositories(:javascript)))
          assert_redirected_to(root_url)
        end
      end
    end

    test 'failed pundit authorization to destroy an existing repository for anonymous user' do
      assert_no_difference(-> { Repository.count }) do
        assert_no_performed_jobs(only: RemoveGithubWebhookJob) do
          sign_out
          delete(repository_url(repositories(:ruby)))
          assert_redirected_to(root_url)
        end
      end
    end

    test 'should update an existing repository from Github' do
      repo_attributes = %w[name full_name description html_url github_created_at github_updated_at clone_url]
      github_attributes = %w[name full_name description html_url created_at updated_at clone_url]
      github_repository = JSON.parse(load_fixture('files/found_github_repository.json'))
      repository = repositories(:ruby)

      assert_performed_with(job: UpdateRepositoryInfoJob, args: [repository.id]) do
        patch(update_from_github_repository_url(repository))

        repository.reload
        repo_attributes.zip(github_attributes).each do |repo_attr, github_attr|
          assert { repository[repo_attr] == github_repository[github_attr] }
        end
      end
    end

    test 'failed pundit authorization to update an existing foreign repository' do
      repository = repositories(:javascript)

      assert_no_performed_jobs(only: UpdateRepositoryInfoJob) do
        patch(update_from_github_repository_url(repository))
        assert_redirected_to(root_url)
        assert { repository.attributes == repository.reload.attributes }
      end
    end

    test 'failed pundit authorization to update an existing repository for anonymous user' do
      repository = repositories(:ruby)

      assert_no_performed_jobs(only: UpdateRepositoryInfoJob) do
        sign_out
        patch(update_from_github_repository_url(repository))
        assert_redirected_to(root_url)
        assert { repository.attributes == repository.reload.attributes }
      end
    end
  end
  # rubocop:enable Metrics/ClassLength
end
