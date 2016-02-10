module JSRuntime
  include AngularHelper

  def eval(command)
    runtime.eval(command)
  end

  private

  def runtime
    @runtime ||= ExecJS.compile(execjs_asset)
  end

  def execjs_asset
    File.read [:public, client_asset_path(:"execjs.min.js")].join('/')
  end

end
