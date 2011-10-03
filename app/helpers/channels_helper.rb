module ChannelsHelper

  def partial_from params
    partial = 'user_channel'

    if params[:create_from_android]
    		partial = 'new_android_channel'
  	end 

    if params[:create_from_desktop]
    		partial = 'new_desktop_channel'
  	end

    if params[:show_desktop_local_gateway] 
    		partial = 'download_desktop_local_gateway'
   	end

    if params[:show_android_local_gateway]
    		partial = 'download_android_local_gateway'
  	end

    if params[:choose_local_gateway]
    		partial = 'choose_local_gateway'
  	end

    if params[:show_local_gateway]
    		partial = 'choose_local_gateway'
  	end

    if params[:show_current]
    		partial = 'user_channel'
  	end
  	
  	partial
	end
end
