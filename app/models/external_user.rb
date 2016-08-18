class ExternalUser

  #check if the user project has software engineer external role and display only
  #the code given in project file withing [] brackets
  def getexternaluser_project_name(existingproject)
    if User.current.roles_for_project(existingproject).include?Role.find_by_id(27)
      testresult= existingproject.name.scan(/\[([^\]]*)\]/)[-1]
      if testresult!=nil
        return testresult[0]
      else
        return existingproject.name
      end
    else
      return existingproject.name

    end
  end

  #check if a user has software engineer external role within a user list
  def check_if_user_has_external_role(userlist,selectedproject)
    begin
      isexternaluser=false
      role=Role.find_by_id(27)
      userlist.each do |mail_user|

        if (mail_user.roles_for_project(selectedproject).include?role)
          isexternaluser=true
          break
        else
          isexternaluser=false
        end

      end
      return isexternaluser
    rescue Exception=>e
    else
      return false
    end
  end


  def external_user_mail_subject(projectname)
    testresult= projectname.scan(/\[([^\]]*)\]/)[-1]
    if testresult!=nil
      return testresult[0]
    else
      return projectname
    end
  end

end
