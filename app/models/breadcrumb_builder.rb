class BreadcrumbBuilder < BreadcrumbsOnRails::Breadcrumbs::Builder
  
  def render
    "<ul>#{@elements.map{|e| "<li>#{item e}</li>"}.join}</ul>"
  end
  
  def item element
    @context.link_to_unless_current(compute_name(element), compute_path(element))
  end
  
end