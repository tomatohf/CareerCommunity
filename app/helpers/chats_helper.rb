module ChatsHelper

  def juggernaut_show_channels_for_client(client_id)
    fc = {
      :command    => :query,
      :type       => :show_channels_for_client,
      :client_id   => client_id.to_s
    }
    Juggernaut.send_data(fc, true).flatten
  end
  
  def get_channels_of_account(account_id)
    juggernaut_show_channels_for_client(account_id)
  end
  
  def online?(account_id)
    get_channels_of_account(account_id).include?(ChatsController::Community_Channel_Name)
  end
  
end

