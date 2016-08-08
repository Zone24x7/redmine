class CheckRole

  #check if any project has software- engineer external role
  def check_external_user (projectlist)
    @restult=false
    projectlist.each do |projectitem|
      if User.current.roles_for_project(projectitem).include?Role.find_by_id(27)
        @restult= true
      else
        @result=false
      end
    end
    return @restult
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
