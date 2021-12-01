class EventsController < ApplicationController
  require 'uri'
  require 'net/http'

  def index
    @events = Event.all
  end

  def new
    @event = Event.new
    @user = current_user
  end

  def create
    @event = Event.new(event_params)
    @transaction.save ? (redirect_to event_path(@event)) : (render :new)
  end

  def edit
    @event = Event.find(params[:id])
  end

  def update
    @event = Event.find(params[:id])
    @event.update(event_params)
    redirect_to event_path(@event)
  end

  def show
    @user = current_user
    @event = Event.find(params[:id])
    @actions_held = @user.investments.find_by(event: @event).n_actions
    @offers = @event.transactions.where(buyer_id: nil).order(price: :asc)

    uri = URI("http://api.mediastack.com/v1/news")
    params = {
      'access_key' => ENV["MEDIASTACK_ACCESS_KEY"],
      'search' => @event.title,
      'limit' => 6,
      'languages' => 'en'
    }
    uri.query = URI.encode_www_form(params)
    response = Net::HTTP.get_response(uri)
    news_json = response.read_body
    data_news = JSON.parse(news_json)
    @data = data_news["data"]
    # @news["data"][0]["title"] --> accéder au titre du Hash dans array dans Data
  end

  private

  def event_params
    params.require(:event).permit(:title, :description, :end_date)
  end
end
