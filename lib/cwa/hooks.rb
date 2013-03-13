module Cwa
  class Hooks < Redmine::Hook::ViewListener
    # This just renders the partial in
    # app/views/hooks/my_plugin/_view_issues_form_details_bottom.rhtml
    # The contents of the context hash is made available as local variables to the partial.
    #
    # Additional context fields
    #   :issue  => the issue this is edited
    #   :f      => the form object to create additional fields
    #render_on :view_layouts_base_sidebar,
    #          :partial => 'hooks/view_layouts_base_sidebar'

    def view_layouts_base_sidebar(context={ })
      controller = context[:request][:controller]
      action     = context[:request][:action]
      if context[:controller].lookup_context.exists?("#{controller}/#{action}_sidebar", {}, true)
        Rails.logger.debug "view_layouts_base_sidebar() => " + context[:request].path_parameters.to_s
        context[:controller].send(:render_to_string, {
          :partial => "#{controller}/#{action}_sidebar",
          :locals => context
        })
      end
    end
  end
end
