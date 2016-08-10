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
end