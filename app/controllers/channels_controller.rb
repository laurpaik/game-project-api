class ChannelsController < ProtectedController
  before_action :set_channel, only: [:update, :destroy]

  # GET /channels
  # GET /channels.json
  def index
    @channels = current_user.channels.all

    render json: @channels
  end

  # GET /channels/1
  # GET /channels/1.json
  def show
    render json: current_user.channels.find(params[:id])
  end

  # POST /channels
  # POST /channels.json
  def create
    @channel = current_user.channels.build(channel_params)

    if @channel.save
      render json: @channel, status: :created
    else
      render json: @channel.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /channels/1
  # PATCH/PUT /channels/1.json
  def update
    if @channel.update(channel_params)
      head :no_content
    else
      render json: @channel.errors, status: :unprocessable_entity
    end
  end

  # DELETE /channels/1
  # DELETE /channels/1.json
  def destroy
    @channel.destroy

    head :no_content
  end

  def set_channel
    @channel = Channel.find_by(id: params[:id], user: current_user)
  end
  private :set_channel

  def channel_params
    params.require(:channel).permit(:name)
  end
  private :channel_params
end
