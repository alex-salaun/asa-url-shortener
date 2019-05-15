class UrlsController < ApplicationController
  def index
    # init a nex url entity for the form
    @url  = Url.new
    # load all the existing urls
    @urls = Url.order(created_at: :desc)
  end

  def show
    # get the url entity with the given slug
    @url = Url.find_by(slug: params[:slug])

    # if an url entity exists and is not expired, the user is redirected to the original url
    if @url && !@url.expired?
      @url.update_attribute(:hits, @url.hits + 1)
      redirect_to @url.origin_url
    else
      # the is redirect to the homepage if there is no url with this slug or if it is expired
      redirect_to root_path, alert: I18n.t('controllers.messages.urls.show.error')
    end
  end

  def create
    @url = Url.new(url_params)

    if @url.save
      redirect_to root_path, notice: I18n.t('controllers.messages.urls.create.success')
    else
      @urls           = Url.order(created_at: :desc)
      flash.now.alert = I18n.t('controllers.messages.urls.create.error')
      render :index
    end
  end

  def update
    @url = Url.find(params[:id])
    if @url.update(url_params)
      redirect_to root_path, notice: I18n.t('controllers.messages.urls.update.success')
    else
      redirect_to root_path, alert: I18n.t('controllers.messages.urls.update.error')
    end
  end

  private

  def url_params
    # only origin_url (for the creation) and epxiration_date (for the update) could be set from the views
    params.require(:url).permit(:origin_url, :expiration_date)
  end
end
