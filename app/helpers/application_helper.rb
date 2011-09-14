module ApplicationHelper
  def link_to_remove_fields(name, f, options={})
    f.hidden_field(:_destroy) + link_to_function(name, "remove_fields(this)", options)
  end
  
  def link_to_edit_fields(name, f, association, edit_object, options={})
    fields = edit_fields_for f, association, edit_object, options
    
    link_to_function(name, "edit_fields(this, \"#{escape_javascript(fields)}\")", :class => 'farrow')
  end
  
  def edit_fields_for(f, association, edit_object, options={})
    f.fields_for(association, edit_object, :child_index => edit_object, :index => options[:index]) do |builder|
      render(association.to_s.singularize + "_controls", :f => builder)
    end
  end

  def link_to_add_fields(name, f, association, options={})
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render(association.to_s.singularize + "_add", :f => builder, :index => "new_#{association}")
    end
    link_to_function(name, "add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\")", options)
  end
  
  def link_button_to(body, url, html_options = {})
    default_options = { :type => 'button', :class => 'white' }
    onclick = "window.location='#{url}';return false;"
    
    content_tag(:button, body, default_options.merge(html_options.merge(:onclick => onclick)))
  end
end
