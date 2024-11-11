# app/controllers/sessions_controller.rb
class SessionsController < ApplicationController
  def create
    auth = request.env['omniauth.auth']

    user = User.find_or_create_by(email: auth['info']['email']) do |u|
      u.nickname = auth['info']['nickname']
      u.name = auth['info']['name']
      u.image_url = auth['info']['image']
      u.token = auth['credentials']['token']
    end

    user.update(
      nickname: auth['info']['nickname'],
      name: auth['info']['name'],
      image_url: auth['info']['image'],
      token: auth['credentials']['token']
    )

    session[:user_id] = user.id
    flash[:notice] = "Successfully logged in!"
    redirect_to root_path
  end

  def destroy
    session[:user_id] = nil
    flash[:notice] = "Successfully logged out!"
    redirect_to root_path
  end
end
