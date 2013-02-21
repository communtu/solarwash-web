module ProgramsHelper
	def programs_of_device device_id
    Device.all.map do |d|
       if(d.progam_id == device_id)
         ["Gruppe #{g.id}",g.id]
       else
         nil
       end
     end
	end
end