# frozen_string_literal: true

class ListenersController < ProtectedController
  include ActionController::Live
  skip_before_action :authenticate, only: :watch
  # before_action :query_string_authenticate, only: :watch

  private

  def query_string_authenticate
    token = params[:token]
    @current_user = AUTH_BLOCK.call(token)
    head :unauthorized unless current_user
  end

  # FIXME this needs to go back to 30 seconds at some point... changed it to 10 for time reasons
  HEARTBEAT = 10

  def start_heartbeat
    Thread.new do
      count = 0
      until @queue.closed?
        @queue.push heartbeat: count += 1
        sleep HEARTBEAT
      end
    end
  end

  def handle_notify
    @channel.listen_for_event(@timeout) do |_event, data|
      @queue.push data
    end
    @queue.push timeout: 'watch timed out'
    @queue.close
  end

  def start_notify
    Thread.new do
      handle_notify
    end
  end

  public

  def watch
    @queue = Queue.new
    # didn't recognize current_user.id
    @channel = Channel.where(user: current_user)
    @timeout = params[:timeout] ? params[:timeout].to_i : 120
    heartbeat = start_heartbeat
    notify = start_notify
    response.headers['Content-Type'] = 'text/event-stream'
    sse = SSE.new(response.stream)
    begin
      until @queue.closed?
        event = @queue.pop
        sse.write event
      end
    rescue IOError, ClientDisconnected => e
      logger.info e.to_s + ': ' + Time.now.to_s
    ensure
      logger.info 'Streaming thread stopped: ' + Time.now.to_s
      sse.close
    end
    notify.join
    heartbeat.join
  end
end
