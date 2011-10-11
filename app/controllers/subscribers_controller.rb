class SubscribersController < AuthenticatedController
  
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
    @subscribers = Subscriber.where(:schedule_id => params[:schedule_id]).page(params[:page]).per(10)

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
end
