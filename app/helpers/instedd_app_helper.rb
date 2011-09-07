module InsteddAppHelper
  
end

module DeviseHelper  
  def devise_error_messages!
    (content_tag :div, :class => 'centered box w30 error_description' do
      (content_tag :h2, 'The following errors occurred') \
      + \
      (content_tag :ul do
        raw resource.errors.full_messages.map { |msg| content_tag(:li, msg) }.join
      end)
    end)
  end
end