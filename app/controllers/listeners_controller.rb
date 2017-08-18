# frozen_string_literal: true

class ListenersController < ProtectedController
  include ActionController::Live
  skip_before_action :authenticate, only: :watch
  before_action :query_string_authenticate, only: :watch

  private

  def query_string_authenticate
    token = params[:token]
    @current_user = AUTH_BLOCK.call(token)
    head :unauthorized unless current_user
  end

  def base_query
    Channel.where(user: current_user.id)
  end

  HEARTBEAT = 30

# start a new thread, until the queue is closed then keep adding
# to the heartbeat... delay the loop for 30 sec?
  def start_heartbeat
    Thread.new do
      count = 0
      until @queue.closed?
        @queue.push heartbeat: count += 1
        sleep HEARTBEAT
      end
    end
  end

# listen for the timeout, push the data, close the queue?
  def handle_notify
    # see listen_notify for notes on listen_for_update
    # basically open a connection and listener, and if something happens, push the data
    Channel.listen_for_update(@timeout) do |_event, data| # it'll just be listen, not listen_for_update
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
    @channel = base_query.find(params[:id])
    # if there's a timeout, turn it to an integer, default 120
    @timeout = params[:timeout] ? params[:timeout].to_i : 120
    heartbeat = start_heartbeat
    notify = start_notify
    response.headers['Content-Type'] = 'text/event-stream'
    # sse = server sent event
    sse = SSE.new(response.stream)
    begin
      until @queue.closed?
        # queue.pop retrieves data from the queue
        event = @queue.pop
        sse.write event
      end
    rescue IOError, ClientDisconnected => e
      # this happens if the exception happens
      logger.info e.to_s + ': ' + Time.now.to_s
    ensure
      # always happens
      logger.info 'Streaming thread stopped: ' + Time.now.to_s
      sse.close
    end
    notify.join
    heartbeat.join
  end
end
