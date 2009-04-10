module JobTargetsHelper
  
  def get_target_name(target_or_id, company = nil, target_info = nil, job_position = nil)
    target = get_target_obj(target_or_id)
    
    company_name = get_target_company_name(target, company, target_info)
    
    job_position ||= JobPosition.get_job_position(target.job_position_id)
    
    append_job_position_name(company_name, job_position)
  end
  
  def append_job_position_name(company_name, job_position, sep = ["(", ")"])
    target_name = company_name
    
    target_name += " #{sep[0]}#{job_position.name}#{sep[1]}" unless (job_position.id == JobPosition::Null_Record_ID)
    
    target_name
  end
  
  def get_target_company_name(target_or_id, company = nil, target_info = nil)
    target = get_target_obj(target_or_id)
    
    company ||= Company.get_company(target.company_id)
    
    target_info ||= target.get_info
    
    (company.id == Company::Null_Record_ID) ? target_info[:refer_name] : company.name
  end
  
  def get_target_obj(target_or_id)
    target_or_id.kind_of?(JobTarget) ? target_or_id : JobTarget.get_target(target_or_id)
  end
  
end


