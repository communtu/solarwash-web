module GroupsHelper
  
  def possible_groups
     Group.all.map do |g|
       if(g.users.count < 2)
         ["Gruppe #{g.id}",g.id]
       else
         nil
       end
     end
  end
  
end
