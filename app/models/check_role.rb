class CheckRole

  #check if any project has software- engineer external role
  @isexternalUser=false

  def check_external_user (projectlist)
    role = Role.find_by_id(27)
    projectlist.each do |project_item|
      if (User.current.roles_for_project(project_item).include? role)
        @isexternalUser= true
        break
      else
        @isexternalUser=false
      end
    end
    return @isexternalUser
  end

  #check if the given project has a software engineer -external role
  def iscurrent_user_external_user (projectitem)
    if User.current.roles_for_project(projectitem).include?Role.find_by_id(27)
      return true
    else
      return false
    end
  end

end
