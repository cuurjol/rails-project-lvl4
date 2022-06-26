# frozen_string_literal: true

module Web
  module Repositories
    class ChecksController < Web::ApplicationController
      def create
        authorize(Repository::Check)
        check = current_user.repositories.find(params[:repository_id]).checks.create
        ExecuteRepositoryCheckJob.perform_later(check.id)
        redirect_to(repository_path(check.repository), notice: t('.success'))
      end

      def show
        @check = Repository::Check.find(params[:id])
        authorize(@check)
      end
    end
  end
end
