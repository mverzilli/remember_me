class ApplicationController < ActionController::Base
  protect_from_forgery
  def after_sign_in_path_for user
  	schedules_path
  end
  def after_inactive_sign_up_path_for user
    tour_path(1)
  end
  def after_sign_up_path_for user
     tour_path(1)
  end

end
