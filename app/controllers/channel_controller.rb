class ChannelController < AuthenticatedController

  def new
  end

  def create
    unless params[:show_local_gateway]
      current_user.register_channel params[:channel][:code]
      params[:show_current] = true
      render :action => "new"
    end
  rescue NuntiumException => exception
    @invalid_channel = Channel.new
    
    exception.properties.map do |value, msg|
       @invalid_channel.errors.add((value.humanize + ': '), msg)
    end       
    render :action => "new"
  end

  # # GET /channels/1
  # # GET /channels/1.xml
  #   def show
  #     @channel = Channel.find(params[:id])
  # 
  #     respond_to do |format|
  #       format.html # show.html.erb
  #       format.xml  { render :xml => @channel }
  #     end
  #   end
   
   
   # DELETE /channels/1
   # DELETE /channels/1.xml
   def destroy
     @channel = Channel.find(params[:id])
     @channel.destroy

    respond_to do |format|
      format.html { redirect_to(schedules_url) }
      format.xml  { head :ok }
    end
   end

end
