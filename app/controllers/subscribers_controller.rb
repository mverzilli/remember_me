class SubscribersController < AuthenticatedController
  helper_method :sort_column, :sort_direction
    
  def initialize
    super
    @show_breadcrum = true
    add_breadcrumb "Reminders", :schedules_path
  end
  
  
  # GET /subscribers
  # GET /subscribers.xml
  def index
    add_breadcrumb Schedule.find(params[:schedule_id]).title, schedule_path(params[:schedule_id])
    add_breadcrumb "Subscribers", schedule_subscribers_path(params[:schedule_id])
    @subscribers = Subscriber.where(:schedule_id => params[:schedule_id]).page(params[:page]).per(10).order(sort_column + " " + sort_direction)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @subscribers }
      format.csv do
        @subscribers = Subscriber.where(:schedule_id => params[:schedule_id])
        render :csv => @subscribers
      end
    end
  end

  # DELETE /subscribers/1
  # DELETE /subscribers/1.xml
  def destroy
    @subscriber = Subscriber.find(params[:id])
    @subscriber.destroy

    respond_to do |format|
      format.html { redirect_to(schedule_subscribers_url, :schedule_id => params[:schedule_id]) }
      format.xml  { head :ok }
    end
  end
  
  def sort_column
     Subscriber.column_names.include?(params[:sort]) ? params[:sort] : "subscribed_at"
  end

  def sort_direction
     %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end
end
