module JobTargetsHelper
  
  def get_target_name(target_or_id)
    target = get_target_obj(target_or_id)
    
    # To Be Implemented ...
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


