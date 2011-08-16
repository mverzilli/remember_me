class ChannelsController < AuthenticatedController

  def new    
  end
  
  def create
    current_user.register_channel params[:channel][:code]
    redirect_to :schedules
  end

end
