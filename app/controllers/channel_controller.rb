class ChannelController < AuthenticatedController

  def new
  end

  def create
    unless params[:show_local_gateway]
      @channel = current_user.register_channel params[:channel][:code]
      params[:step] = "end_wizard"
      render :action => "new"
    end
  rescue Nuntium::Exception => exception
    @channel = Channel.new
    load_errors_from exception
    params[:step] = "user_channel"
    render :action => "new"
  end   
   
   # DELETE /channels/1
   # DELETE /channels/1.xml
   def destroy
     @channel = Channel.find(params[:id])
     @channel.destroy

     respond_to do |format|
       format.html { redirect_to(schedules_url, :notice => 'Channel was successfully deleted.') }
       format.xml  { head :ok }
     end
  rescue Nuntium::Exception => exception
    load_errors_from exception
    params[:step] = "user_channel"
    render :action => "new"
  end
  
  def load_errors_from exception
    if exception.properties.empty?
      @channel.errors.add('Unexpected Error: ', "\"#{exception.message}\"")
    end
    exception.properties.map do |value, msg|
      @channel.errors.add(("#{value.humanize}: "), msg)
    end
  end
  
end
