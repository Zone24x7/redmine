class CheckRole

  def check_external_user (projectlist)

    projectlist.each do |projectitem|
      if User.current.roles_for_project(projectitem).include?Role.find_by_id(27)
        return true
      end
    end

  end
end
