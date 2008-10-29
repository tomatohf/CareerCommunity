module VotesHelper
  
  def get_text_result_info_for_vote(topic_id)
    get_text_result_info_for_vote_or_cross_analysis(topic_id, :get_count_by_option)
  end

#  def get_voting_text_result_info_from_cross_analysis_result(topic_id, action_args)
#    factor = action_args["factor"]
#    value_keys = action_args.keys.select {|k| k =~ /^value/}
#    values = value_keys.map {|key| action_args[key]}
#
#    if values.size <= 0 || values[0] ==  nil
#      return get_text_result_info_for_vote_or_cross_analysis(topic_id, :count_by_option_and_anonymouse_member)
#    end
#
#    get_text_result_info_for_vote_or_cross_analysis(topic_id, "count_by_option_and_member_field_" + factor, values)
#  end

#  def get_voting_text_result_info_from_vote_constituent_result(topic_id, action_args)
#    factor = action_args["factor"]
#    return [[], nil, false] if factor == "time"
#
#    categories, series = VoteRecord.send("count_by_member_constituent_" + factor, topic_id)
#
#    option_info = []
#    total_count = 0
#    categories.each_index do |i|
#      index = (i + 65).chr
#      count = series[i]
#      color = get_random_init_color.join
#      option_info << {:index => index, :title => categories[i], :color => color, :count => count}
#      total_count = total_count + count
#    end
#    [option_info, total_count, false]
#  end

  def get_text_result_info_for_vote_or_cross_analysis(topic_id, count_function, count_args = [])
    options = VoteOption.get_vote_topic_options(topic_id)
    option_info = []
    total_count = 0
    options.each_index do |i|
      o = options[i]
      index = (i + 65).chr
      count = VoteRecord.send(count_function, o[0], *count_args)
      color = if o[2]
                  o[2]
                else
                  get_random_init_color
                end
      option_info << {:index => index, :title => o[1], :color => color, :count => count, :option => o}
      total_count = total_count + count
    end
    [option_info, total_count, true]
  end
  
end

