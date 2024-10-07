class GenericWorker
  include Sidekiq::Worker

  def perform(class_name, method_name, arg1 = nil, arg2 = nil, arg3 = nil, arg4 = nil, arg5 = nil)
    class_name.constantize.send(method_name, *([arg1, arg2, arg3, arg4, arg5].compact))
  end
end
