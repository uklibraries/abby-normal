class ApiConstraints
  def initialize(options)
    @version = options[:version]
    @default = options[:default]
  end

  def matches?(req)
    @default || req.headers['Accepts'].include?("application/vnd.presence.abby.normal.v#{@version}")
  end
end
