# frozen_string_literal: true

module Web
  class ApplicationController < ApplicationController
    include Pundit::Authorization
    include AuthManagement

    before_action :authenticate_user!

    helper_method :signed_in?, :current_user

    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

    private

    def user_not_authorized
      flash[:alert] = t('flash.not_authorized')

      redirect_to root_path
    end
  end
end
