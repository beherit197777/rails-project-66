# frozen_string_literal: true

module Web
  class RepositoriesController < Web::ApplicationController
    def index
      @repositories = current_user.repositories.includes(:checks).page(params[:page])
    end

    def show
      @repository = ::Repository.find(params[:id])

      authorize @repository

      @checks = @repository.checks.order(id: :desc).page(params[:page])
    end

    def new
      @repository = current_user.repositories.build
      @github_client = AppContainer[:github_client].new(repository: @repository, user: current_user)
      authorize @repository

      @repositories = fetch_github_repositories
    end

    def create
      @github_client = AppContainer[:github_client].new(user: current_user)
      @repository = current_user.repositories.build(repository_params)

      authorize @repository
      if @repository.save!
        UpdateInfoRepositoryJob.perform_now(@repository.id)
        redirect_to repositories_path, notice: t('.success')
      else
        Rails.logger.error "Failed to save repository: #{@repository.errors.full_messages.join(', ')}"
        @repositories = fetch_github_repositories
        flash[:alert] = @repository.errors.full_messages.join('\n')
        render :new
      end
    end

    private

    def repository_params
      params.require(:repository).permit(:github_id).merge(
        name: selected_repository_name
      )
    end

    def selected_repository_name
      repo_id = params[:repository][:github_id]
      repositories = fetch_github_repositories
      repo = repositories.find { |r| r[1].to_s == repo_id.to_s } # Преобразуем оба значения в строку
      repo ? repo[0] : nil
    end


    def fetch_github_repositories
      @github_client ||= AppContainer[:github_client].new(user: current_user)
      cache_key = "#{current_user.cache_key_with_version}/github_repositories"
      Rails.cache.fetch(cache_key, expires_in: 12.hours) do
        repos = @github_client.repos_collection
        Rails.logger.info "Fetched repositories: #{repos.inspect}"
        repos
      end
    end

  end
end
