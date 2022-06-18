# frozen_string_literal: true

module Web
  class RepositoriesController < Web::ApplicationController
    def index
      authorize(Repository)
      @search = Repository.ransack(params[:q])
      @pagy, @repositories = pagy(@search.result.order(created_at: :desc))
    end

    def new
      authorize(Repository)
      @repository = Repository.new
    end

    def create
      authorize(Repository)
      @repository = current_user.repositories.build(repository_params)

      if @repository.save
        UpdateRepositoryInfoJob.perform_later(@repository.github_id)
        redirect_to(repositories_path, notice: t('.success'))
      else
        flash.now.alert = t('.failure')
        render(:new, status: :unprocessable_entity)
      end
    end

    def show
      authorize(repository)
    end

    def destroy
      authorize(repository)
      repository.destroy
      redirect_to(repositories_path, notice: t('.success'))
    end

    def update_from_github
      authorize(repository)
      UpdateRepositoryInfoJob.perform_later(repository.github_id)
      redirect_to(repository, notice: t('.success'))
    end

    private

    def repository
      @repository ||= Repository.find(params[:id])
    end

    def repository_params
      params.require(:repository).permit(:github_id)
    end
  end
end
