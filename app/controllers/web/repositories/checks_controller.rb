# frozen_string_literal: true

module Web
  module Repositories
    class ChecksController < Web::ApplicationController
      def create
        authorize(Repository::Check)
        check = current_user.repositories.find(params[:repository_id]).checks.create!
        ExecuteRepositoryCheckJob.perform_later(check.id)
        redirect_to(repository_path(check.repository), notice: t('.success'))
      end

      def show
        authorize(check)
        @pagy_offense_files, @offense_files = build_offense_files_pagy
        @offenses_with_pagies = @offense_files.map.with_index do |offense_file, index|
          build_offenses_pagy(offense_file, index)
        end
      end

      private

      def check
        @check ||= Repository::Check.find(params[:id])
      end

      def build_offense_files_pagy
        vars = {
          url: repository_check_url(check.repository.id, check.id),
          page_param: :offense_files,
          link_extra: 'data-remote="true"'
        }
        pagy_array(check.offense_files || [], vars)
      end

      def build_offenses_pagy(offense_file, index)
        vars = {
          page: params[:table_offenses].present? && params[:table_offenses].to_i == index ? params[:offenses] : 1,
          page_param: :offenses,
          params: { table_offenses: index },
          link_extra: 'data-remote="true"'
        }
        pagy_array(offense_file['offenses'], vars)
      end
    end
  end
end
