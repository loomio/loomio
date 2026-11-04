# frozen_string_literal: true

module Hocuspocus
  # Runs jobs one at a time, in order, on a shared thread pool. Each socket
  # gets one, giving it the in-order processing that Node's event loop gives
  # Hocuspocus, while different sockets run in parallel.
  class SerialQueue
    BATCH_SIZE = 32 # jobs per turn on the pool, so one busy socket cannot hog a thread

    def initialize(executor, error_handler)
      @executor = executor
      @error_handler = error_handler
      @mutex = Mutex.new
      @jobs = []
      @running = false
    end

    def post(&job)
      @mutex.synchronize do
        @jobs << job
        return if @running

        @running = true
      end
      @executor.post { drain }
    end

    private

    def drain
      BATCH_SIZE.times do
        job = @mutex.synchronize do
          @jobs.shift.tap { |next_job| @running = false if next_job.nil? }
        end
        return if job.nil?

        begin
          job.call
        rescue StandardError => e
          @error_handler.call(e)
        end
      end
      @executor.post { drain }
    end
  end
end
