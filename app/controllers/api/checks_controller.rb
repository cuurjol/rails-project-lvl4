# frozen_string_literal: true

module Api
  class ChecksController < Api::ApplicationController
    def create
      repository = Repository.find_by(github_id: params[:repository][:id])
      check = repository.checks.create!
      ExecuteRepositoryCheckJob.perform_later(check.id)
      head(:ok)
    end
  end
end
