module PushRelay
  class Error < StandardError
    attr_reader :status, :code, :retry_after

    def initialize(status, code, retry_after: nil)
      @status, @code, @retry_after = status, code, retry_after
      super(code)
    end
  end
end
