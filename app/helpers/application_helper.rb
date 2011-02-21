module ApplicationHelper
  def render2(options)
    render(options.merge({:locals => options}))
  end
end
