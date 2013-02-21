module ProgramsHelper
	def programs_of_device device_id
    Programs.all.map do |p|
       if(p.device_id == device_id)
         ["Gruppe #{g.id}",g.id]
       else
         nil
       end
	end
end