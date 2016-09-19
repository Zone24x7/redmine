include IssuesTagsHelper
module RedmineTags
  module Hooks
    class ViewsIssuesHook < Redmine::Hook::ViewListener
      render_on :view_issues_show_details_bottom, partial: 'issues/tags'
      render_on :view_issues_form_details_bottom, partial: 'issues/tags_form'
      render_on :view_issues_sidebar_planning_bottom, partial: 'issues/tags_sidebar'

      def view_issues_context_menu_end(context={ })

        issues = context[:issues]
        @back = context[:back]
        @can = context[:can]
        task_ids = []
        project_id = 0
        issues.each do |issue|
          project_id = issue.project_id.to_i
          task_ids << issue.id
        end

        # get project id or project parent id
        project_id = get_project_id(project_id)

        if User.current.logged?
          snippet ='<li class="folder">'
          snippet += '<a href="#" class="submenu">'+ l(:tags) + '</a>'
          snippet += '<ul><li class="folder"><a href="#" class="submenu">'+l(:remove_tags)+'</a><ul>'
          tags = loadTagsByProject(project_id)
          if tags.size>0
            issue_tags =[]

            #get issue tags by issue id
            if(task_ids.length==1)
              issue_tags = loadTagsByIssue(task_ids[0])
            end
            tags.each do |tag|
              tag_name = tag[0]
              tag_id = tag[1]

              # snippet to display remove tag context menu item
              snippet += <<EOHTML
                            <li>
                              #{context_menu_link tag_name, bulk_update_issues_path(:ids => task_ids, :tag_id => tag_id, :tags_action => 'remove',  :back_url => @back), :method => :post, :selected => ( issue_tags.include?(tag_id)), :disabled => !@can[:edit], :only_path => true}
                            </li>
EOHTML
            end
          end
          snippet +='</ul></li>'
          snippet +='<li class="folder"><a href="#" class="submenu">'+l(:edit_tags)+'</a><ul>'
          if tags.size>0
            tags.each do |tag|
              tag_name = tag[0]
              tag_id = tag[1]

              #snippet to display edit tag context menu item
              snippet += <<EOHTML
                            <li>
                              #{context_menu_link tag_name, bulk_update_issues_path(:ids => task_ids, :tag_id => tag_id, :tags_action => 'update',  :back_url => @back), :method => :post, :selected => ( issue_tags.include?(tag_id)), :disabled => !@can[:edit]}
                            </li>
EOHTML
            end
          end
          snippet +='</li></ul></li>'
        end
      end

      # loadTagsByProject method to get tags by project
      def loadTagsByProject(project_id)
        sql_query ="select distinct t.name,t.id from tags as t,taggings as ta,issues as i ,projects as p where t.id=ta.tag_id and ta.taggable_id = i.id and i.project_id = p.id and ( p.id = #{project_id} or p.parent_id =#{project_id} ) order by lower(t.name)"
        tags = ActiveRecord::Base.connection.execute(sql_query)
        ActiveRecord::Base.connection.close
        tags
      end

      # loadTagsByIssue method to get tags assigned to issue
      def loadTagsByIssue(issue_id)
        sql_query ="select distinct t.id from tags as t,taggings as ta,issues as i where t.id=ta.tag_id and ta.taggable_id = i.id and i.id = #{issue_id} order by lower(t.name)"
        tags = ActiveRecord::Base.connection.execute(sql_query)
        ActiveRecord::Base.connection.close
        issue_tags =  []
        tags.each do |tag_id|
          issue_tags << tag_id[0]
        end
        issue_tags
      end

      def context_menu_link(name, url, options={})
        options[:class] ||= ''
        if options.delete(:selected)
          options[:class] << ' icon-checked disabled'
          options[:disabled] = true
        end
        link_to h(name), url, options
      end

    end
  end
end
