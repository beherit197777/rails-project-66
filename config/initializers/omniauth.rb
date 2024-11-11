# frozen_string_literal: true

# config/initializers/omniauth.rb
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, ENV['GITHUB_CLIENT_ID'], ENV['GITHUB_CLIENT_SECRET'], scope: 'user,public_repo,admin:repo_hook', provider_ignores_state: Rails.env.development?
end
