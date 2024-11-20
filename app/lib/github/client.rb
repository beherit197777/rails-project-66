# frozen_string_literal: true

require 'octokit'
class Github::Client
  attr_reader :current_repository, :user, :client

  def initialize(repository: nil, user: nil)
    @current_repository = repository
    @user = user || @current_repository&.user
    token = ENV['GITHUB_ACCESS_TOKEN']
    raise 'GITHUB_ACCESS_TOKEN is not set' if token.nil?
    @client = Octokit::Client.new(access_token: token, auto_paginate: true)
  end

  # def repos
  #   @client.repositories
  # end

  def repos_collection
    repos = client.repositories
    # сюда нужно добавить rep[:language] и чтобы выводило только репозитории c ruby и javascript
    filtered_repos = repos.select { |rep| %w[Ruby JavaScript].include?(rep[:language]) }
    filtered_repos.map { |rep| [rep[:full_name], rep[:id], rep[:language]] }

    filtered_repos.each do |rep|
      ::Repository.create(
        github_id: rep[1],
        name: rep[0],
        language: rep[2],
        user: @user
      )
    end
    repos
  end

  def get_latest_commit_sha(rep_full_name)
    @client.commits(rep_full_name).first.sha
  end

  def update_repository_info!
    repository_atttributes = repository_params

    current_repository.assign_attributes(repository_atttributes)

    current_repository.save!
  end

  def create_hook
    @client.create_hook(
      @current_repository.full_name,
      'web',
      { url: "#{ENV.fetch('BASE_URL', nil)}/api/checks", content_type: 'json' },
      { events: %w[push], active: true }
    )
  end

  def clone_repository(repository, dir_path)
    system("git clone #{repository.clone_url} #{dir_path}")
    raise 'Failed to clone repository' unless result
  end

  def find_instance_repository(github_id)
    repos.find { |rep| rep[:id] == github_id&.to_i }
  end

  def repository_params
    github_repo_id = current_repository.github_id
    repository_data = user_repositories.find { |repo| repo[:id] == github_repo_id.to_i }

    raise 'Repository not found on GitHub' if repository_data.nil?

    {
      name: repository_data[:name],
      full_name: repository_data[:full_name],
      language: repository_data[:language]&.downcase,
      clone_url: repository_data[:clone_url],
      ssh_url: repository_data[:ssh_url]
    }
  end

  private

  def user_repositories
    @client.repos
  end
end
