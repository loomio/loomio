Thread.new do
  require "objspace"
  ObjectSpace.trace_object_allocations_start
  GC.start()
  ObjectSpace.dump_all(output: File.open("heap#{Time.now.strftime('%Y-%m-%d_%H%M%S')}.json", "w"))
end.join
