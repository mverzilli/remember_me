class Users::RegistrationsController < Devise::RegistrationsController
  
  def success
    @email = params[:email].presence || "you"
  end
  
  protected
  
  def after_inactive_sign_up_path_for(resource)
    flash[:notice] = nil
    users_registrations_success_path :email => resource.email
  end
  
end
