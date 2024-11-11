class RepositoriesController < ApplicationController
  before_action :authenticate_user!

  def index
    @repositories = current_user.repositories
  end

  def new
    client = Octokit::Client.new(access_token: current_user.token, auto_paginate: true)
    @available_repos = client.repos.select { |repo| repo.language == 'Ruby' }
    @repository = Repository.new
  end

  def create
    client = Octokit::Client.new(access_token: current_user.token)
    github_repo = client.repo(params[:repository][:github_id])

    @repository = current_user.repositories.new(
      name: github_repo.name,
      github_id: github_repo.id,
      full_name: github_repo.full_name,
      language: github_repo.language,
      clone_url: github_repo.clone_url,
      ssh_url: github_repo.ssh_url
    )

    if @repository.save
      redirect_to repositories_path, notice: 'Repository successfully added'
    else
      flash[:alert] = 'Failed to add repository'
      render :new
    end
  end
end
