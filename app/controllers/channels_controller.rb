class ChannelsController < AuthenticatedController

  def new
  end
  
  def create
    redirect_to :schedules
  end

end
