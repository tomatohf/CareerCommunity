require "weborb/context"
require "rbconfig"

class ShowService
  
  def show(talk_id)
    talk = Talk.get_talk(talk_id)
    
    return "" unless talk.published || ApplicationController.helpers.talk_editor?(RequestContext.get_session[:account_id])
    
    talk_content = Talk.get_reader_content(talk_id)
    
    unless talk_content
      talk_content = {}
      
      talk_content[:title] = talk.title
      talk_content[:desc] = talk.get_info[:desc]
      talk_content[:publish_time] = ApplicationController.helpers.format_date(talk.publish_at)
      
      talkers = {}
      talk_talkers = TalkTalker.get_talk_talkers(talk.id)
      if talk_talkers.size > 1
        talk_talkers.each_index do |talker_index|
          talker = talk_talkers[talker_index][1]
        
          talkers["talker_#{talker.id}"] = {
            :name => "受访嘉宾#{(talker_index + 65).chr}"
          }
        end
      elsif talk_talkers.size > 0
        talker = talk_talkers[0][1]
        
        talkers["talker_#{talker.id}"] = {
          :name => "受访嘉宾"
        }
      end
      talk_content[:talkers] = talkers
      
      talk_categories = {}
      TalkQuestionCategory.get_talk_question_categories(talk.id).each do |category|
        talk_categories["category_#{category.id}"] = {
          :id => category.id,
          :name => category.name,
          :desc => category.desc
        }
      end
      talk_content[:categories] = talk_categories
      
      questions = []
      TalkQuestion.get_talk_questions(talk.id).each do |q|
        question = {}
        question[:question] = q.question
        question[:summary] = q.summary
        question[:category_id] = q.category_id
        
        answers = []
        TalkAnswer.get_talk_question_answers(q.id).each do |a|
          answer = {}
          answer[:answer] = a.answer
          answer[:summary] = a.summary
          answer[:talker_id] = a.talker_id
          
          answers << answer
        end
        question[:answers] = answers
        
        questions << question
      end
      talk_content[:questions] = questions
      
      
      Talk.set_reader_content_cache(talk.id, talk_content)
    end
    
    talk_content
    
  end
  
end


