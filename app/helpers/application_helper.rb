module ApplicationHelper
  def link_to_remove_fields(name, f, options={})
    f.hidden_field(:_destroy) + link_to_function(name, "remove_fields(this)", options)
  end
  
  def link_to_edit_fields(name, f, association)
    fields = edit_fields_for f, association
    
    link_to_function(name, "edit_fields(this, \"#{escape_javascript(fields)}\")", :class => 'farrow')
  end
  
  def edit_fields_for(f, association)
    render(association.to_s.singularize + "_controls", :f => f)
  end

  def link_to_add_fields(name, f, association, options={})
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render(association.to_s.singularize + "_add", :f => builder)
    end
    link_to_function(name, "add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\")", options)
  end
  
  def link_button_to(body, url, html_options = {})
    default_options = { :type => 'button', :class => 'white' }
    onclick = "window.location='#{url}';return false;"
    
    content_tag(:button, body, default_options.merge(html_options.merge(:onclick => onclick)))
  end

  def section title, url, name, active_controllers = [name]
    active = active_controllers.any?{|controller| controller_name == controller.to_s }
    raw "<li class=\"#{active ? "active" : ""}\">#{link_to title, url}</li>"
  end
  
  def breadcrumb
    raw render_breadcrumbs :builder => BreadcrumbBuilder
  end
  
  def sortable(column, title = nil)
    title ||= column.titleize
    page_number = params[:page]
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
    (link_to title, :sort => column, :direction => direction, :page => params[:page]) + '<span></span>'.html_safe
  end
  def css_sort_class_for column
    column == sort_column ? "sort #{css_sort_direction}" : "sort"
  end
  
  def css_sort_direction
    sort_direction == "asc" ? "up" : "down"
  end
  
end
