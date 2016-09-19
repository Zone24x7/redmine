module RedmineTags
  module Hooks
    class ModelIssueHook < Redmine::Hook::ViewListener
      def controller_issues_edit_before_save(context = {})
        save_tags_to_issue context, true
      end

      def controller_issues_bulk_edit_before_save(context = {})
        save_tags_to_issue context, true
        params = context[:params]
        if params[:ids].present? && params[:tag_id].present? && params[:tags_action].present?
          @task_ids = params[:ids]
          @tag_id = params[:tag_id]
          @action = params[:tags_action]

          # if action is remove go to remove_tags method else go to update tags method
          if(@action.eql? "remove")
            remove_tags(@task_ids,@tag_id)
          else
            edit_tags(@task_ids,@tag_id)
          end
        end

      end

      # Issue has an after_save method that calls reload (update_nested_set_attributes)
      # This makes it impossible for a new record to get a tag_list, it's
      # cleared on reload. So instead, hook in after the Issue#save to update
      # this issue's tag_list and call #save ourselves.
      def controller_issues_new_after_save(context = {})
        save_tags_to_issue context, false
        context[:issue].save
      end

      def save_tags_to_issue(context, create_journal)
        params = context[:params]
        issue = context[:issue]
        if params && params[:issue] && !params[:issue][:tag_list].nil?
          old_tags = issue.tag_list.to_s
          issue.tag_list = params[:issue][:tag_list]
          new_tags = issue.tag_list.to_s
          # without this when reload called in Issue#save all changes will be
          # gone :(
          issue.save_tags
          if create_journal && !(old_tags == new_tags ||
              issue.current_journal.blank?)
            issue.current_journal.details << JournalDetail.new(
              property: 'attr', prop_key: 'tag_list', old_value: old_tags,
              value: new_tags)
          end

          Issue.remove_unused_tags!
        end
      end

      #  remove_tags method to remove tags from task / multiple tasks
      def remove_tags(task_ids, tag_id )

        #query to remove tags from task / multiple tasks
        task_ids.each do |task_id|
          task_id = task_id.to_i
          remove_tags_query ="delete from taggings where taggable_type='Issue' and context ='tags' and tag_id ="+tag_id+" and taggable_id  = #{task_id}"
          ActiveRecord::Base.connection.execute(remove_tags_query)
          ActiveRecord::Base.connection.close
        end
      end

      #  edit_tags method to update tags to task / multiple tasks
      def edit_tags(task_ids,tag_id )
        #query to add tags to task / multiple tasks
        task_ids.each do |task_id|
          task_id = task_id.to_i
          # check tag already exists for task
          tag_exist_query = "select count(*) from taggings WHERE taggable_id = #{task_id} and tag_id=#{tag_id} and taggable_type='Issue' and context='tags'"
          result = ActiveRecord::Base.connection.execute(tag_exist_query)
          ActiveRecord::Base.connection.close
          count = -1 # initialize
          result.each do |row|
            count = row[0]
          end

          #add tags to task if tag not exists for a task
          if count==0
            add_tags_query ="insert into taggings (tag_id,taggable_id,taggable_type,context) values (#{tag_id},#{task_id},'Issue','tags')"
            ActiveRecord::Base.connection.execute(add_tags_query)
            ActiveRecord::Base.connection.close
          end
        end
      end
    end
  end
end
