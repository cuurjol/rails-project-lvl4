# frozen_string_literal: true

module Web
  class RepositoriesController < Web::ApplicationController
    def index
      authorize(Repository)
      @search = Repository.includes(:checks).ransack(params[:q])
      @pagy, @repositories = pagy(@search.result.order(created_at: :desc))
    end

    def new
      authorize(Repository)
      @repository = Repository.new
      @client_repos = ApplicationContainer[:github_client].new(current_user.id, current_user.token).client_repos
    end

    def create
      authorize(Repository)
      @repository = current_user.repositories.build(repository_params)

      if @repository.save
        run_jobs(@repository)
        redirect_to(repositories_path, notice: t('.success'))
      else
        flash.now.alert = t('.failure')
        render(:new, status: :unprocessable_entity)
      end
    end

    def show
      authorize(repository)
      @pagy, @checks = pagy(repository.checks.order(created_at: :desc))
    end

    def destroy
      authorize(repository)
      repository.destroy!
      RemoveGithubWebhookJob.perform_later(repository.github_id, current_user.id)
      redirect_to(repositories_path, notice: t('.success'))
    end

    def update_from_github
      authorize(repository)
      UpdateRepositoryInfoJob.perform_later(repository.id)
      redirect_to(repository, notice: t('.success'))
    end

    private

    def run_jobs(repository)
      UpdateRepositoryInfoJob.perform_later(repository.id)
      CreateGithubWebhookJob.perform_later(repository.github_id, current_user.id)
    end

    def repository
      @repository ||= Repository.find(params[:id])
    end

    def repository_params
      params.require(:repository).permit(:github_id)
    end
  end
end
