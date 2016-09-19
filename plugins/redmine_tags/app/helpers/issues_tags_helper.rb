module IssuesTagsHelper
  def sidebar_tags
    unless @sidebar_tags
      @sidebar_tags = []
      if :none != RedmineTags.settings[:issues_sidebar].to_sym
        @sidebar_tags = Issue.available_tags project: @project,
          open_only: (RedmineTags.settings[:issues_open_only].to_i == 1)
      end
    end
    @sidebar_tags
  end

  def render_sidebar_tags
    render_tags_list sidebar_tags, {
      show_count: (RedmineTags.settings[:issues_show_count].to_i == 1),
      open_only: (RedmineTags.settings[:issues_open_only].to_i == 1),
      style: RedmineTags.settings[:issues_sidebar].to_sym }
  end

  # get_project_id method to get project id or project parent id
  def get_project_id(project_id)
    project = Project.find_by_id(project_id)
    projectId =  project_id
    unless project.nil?
      project_parent_id  = project.parent_id
      unless project_parent_id.nil?
        projectId =  project.parent_id
      end
    end
    projectId
  end

end
