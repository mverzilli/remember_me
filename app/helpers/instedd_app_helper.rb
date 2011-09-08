module InsteddAppHelper
  def flash_message
    res = nil
    
    keys = { :notice => 'flash_notice', :error => 'flash_error', :alert => 'flash_error' }
    
    keys.each do |key, value|
      if flash[key]
        res = content_tag :div, :class => "flash #{value}" do
          content_tag :div do
            flash[key]
          end
        end
      end
    end
    
    res
  end
end

module DeviseHelper  
  def devise_error_messages!
    return if resource.errors.full_messages.empty?
    
    (content_tag :div, :class => 'centered box w30 error_description' do
      (content_tag :h2, 'The following errors occurred') \
      + \
      (content_tag :ul do
        raw resource.errors.full_messages.map { |msg| content_tag(:li, msg) }.join
      end)
    end)
  end
end