class SubscribersController < AuthenticatedController
  # GET /subscribers
  # GET /subscribers.xml
  def index
    @subscribers = Subscriber.paginate(:page => params[:page], :per_page => 5).where(:schedule_id => params[:schedule_id])

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
