class LogsController < AuthenticatedController

  def initialize
    super
    @show_breadcrum = true
    add_breadcrumb "Reminders", :schedules_path
  end  
  
  # GET /logs
  # GET /logs.xml
  def index
    add_breadcrumb Schedule.find(params[:schedule_id]).title, schedule_path(params[:schedule_id])
	  add_breadcrumb "Logs", schedule_logs_path(params[:schedule_id])
	  
	  @logs = Log.where(:schedule_id => params[:schedule_id]).sort_by(&:created_at).reverse
    @logs = Kaminari.paginate_array(@logs).page(params[:page]).per(50)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @logs }
    end
  end
end
