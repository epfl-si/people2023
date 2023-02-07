class ApplicationController < ActionController::Base

  before_action :register_client_origin

  INTRANET_RE = Regexp.new(ENV.fetch("INTRANET_RE", '^128\.17[89]'))

  def homepage
  end

  private

  def register_client_origin
    @is_intranet_client = INTRANET_RE.match?(request.remote_ip)
  end

end
