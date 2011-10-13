class LogsController < AuthenticatedController
  helper_method :sort_column, :sort_direction
  
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

    @logs =Log.where(:schedule_id => params[:schedule_id]).page(params[:page]).per(10).order(sort_column + " " + sort_direction)
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @logs }
    end
  end
  
  def sort_column
     Log.column_names.include?(params[:sort]) ? params[:sort] : "created_at"
  end

  def sort_direction
     %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end
end
