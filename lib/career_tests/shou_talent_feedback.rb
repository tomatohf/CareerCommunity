module CareerTests
  
  class ShouTalentFeedback < CareerTests::Base
    
    def name
      "上海海洋大学人才库系统调研反馈问卷"
    end
    
    def desc
      %Q!
        <div>
          感谢你“使用上海海洋大学人才库系统”（下简称“系统”）。以下问题（全部为选择题）可能花费你几分钟时间，你的回答将帮助我们更好的开发和改善人才库系统，为你提供更好的服务。你的反馈结果仅用于支持本项目的开发及相关评估。
        </div>
        <div>
          我们将从给予反馈的同学中随机选取5名，提供第二份简历的一对一修改。再次感谢你对我们服务的支持和帮助！
        </div>
      !
    end
    
    def questions
      [
        [
          {
            :title => "请为以下系统功能、界面设计和简历服务打分，1为最不满意，5为最满意",
            :level => true
          },
          "",
          
          [
            10,
            "从头制作一份简历时各模块的填写内容和相互关系",
            [10, "1"], [20, "2"], [30, "3"], [40, "4"], [50, "5"]
          ],
          
          [
            20,
            "简历基本信息填写时的界面设计和填写指导",
            [10, ""], [20, ""], [30, ""], [40, ""], [50, ""]
          ],
          
          [
            30,
            "“相关经历”的界面设计和填写指导",
            [10, ""], [20, ""], [30, ""], [40, ""], [50, ""]
          ],
          
          [
            40,
            "简历预览及PDF导出功能",
            [10, ""], [20, ""], [30, ""], [40, ""], [50, ""]
          ],
          
          [
            50,
            "简历修改的请求功能",
            [10, ""], [20, ""], [30, ""], [40, ""], [50, ""]
          ],
          
          [
            60,
            "简历修改和评论功能的界面设计和应用",
            [10, ""], [20, ""], [30, ""], [40, ""], [50, ""]
          ],
          
          [
            70,
            "老师对简历的及时反馈和修改意见",
            [10, ""], [20, ""], [30, ""], [40, ""], [50, ""]
          ],
          
          [
            80,
            "老师针对简历提出的修改建议及评论",
            [10, ""], [20, ""], [30, ""], [40, ""], [50, ""]
          ],
          
          [
            90,
            "系统反馈和建议功能",
            [10, ""], [20, ""], [30, ""], [40, ""], [50, ""]
          ]
        ],
        
        [
          "",
          "",
          [
            100,
            "一对一修改简历的服务中，你认为给你最大帮助的是以下哪项",
            [10, "填写完整简历"],
            [20, "求职意向的填写"],
            [30, "经历的筛选、组织和填写"],
            [40, "经历措辞和“简历用语”"],
            [50, "奖项和荣誉的填写"],
            [60, "技能的填写"],
            [70, "爱好和兴趣的填写"],
            [80, "简历的细节和格式"]
          ],
          
          [
            110,
            "在制作简历时，你最希望得到以下哪项辅导",
            [10, "简历的基本格式和排版（包括是否放照片等）"],
            [20, "如何挑选合适的经历"],
            [30, "如何填写具体经历内容"],
            [40, "哪些是HR喜欢的“简历用语”"],
            [50, "如何让简历和求职意向岗位相匹配"],
            [60, "不同行业、岗位对应届生有哪些要求"],
            [70, "如何写求职意向"],
            [80, "简历写不到一页/超过一页应该怎么办"],
            [90, "在简历中应该填哪些附加信息"]
          ]
        ],
        
        [
          {
            :title => "以下是一些针对制作简历的观点和看法，请按1-5打分，1为最不认同，5为最认同",
            :level => true
          },
          "",
          
          [
            130,
            "简历应根据不同的求职意向岗位“精投”",
            [10, "1"], [20, "2"], [30, "3"], [40, "4"], [50, "5"]
          ],
          
          [
            140,
            "应该把经历分成校园经历、社会经历，这是约定俗成的",
            [10, ""], [20, ""], [30, ""], [40, ""], [50, ""]
          ],
          
          [
            150,
            "经历越多越好，社团职位越高越好",
            [10, ""], [20, ""], [30, ""], [40, ""], [50, ""]
          ],
          
          [
            160,
            "奖励和证书写的越多越好",
            [10, ""], [20, ""], [30, ""], [40, ""], [50, ""]
          ],
          
          [
            170,
            "自我评价很重要，可以体现自己的特点",
            [10, ""], [20, ""], [30, ""], [40, ""], [50, ""]
          ],
          
          [
            180,
            "虽然我没有任何社团经验，但HR应该能体会到我的满腔热情",
            [10, ""], [20, ""], [30, ""], [40, ""], [50, ""]
          ]
        ],
        
        [
          "",
          "",
          [
            190,
            "你是否希望在制作简历时获得第三方（专业机构、HR、老师、学长）的帮助？",
            [10, "是"],
            [20, "否"],
            [30, "无所谓"]
          ],
          
          [
            200,
            {
              :title => "如果对人才库有任何建议和意见，请填写在这里",
              :input_type => :text,
              :multi_line => true
            }
          ],
          
          [
            210,
            {
              :title => "请填写你的学号或姓名，你将有可能获得乔布堂送出的奖品或服务",
              :input_type => :text,
              :multi_line => false
            }
          ]
        ]
      ]
    end
    
    def display_question_title(index, title)
      "<b>#{index+1}. #{title}</b>"
    end
    
    def display_category_title(index, title)
      "第 #{index+1} 部分 #{title}"
    end
    
    def category_title_bg_color
      "F0F3FA"
    end
    
    
    def process_answer(answer)
      
    end
    
    
    def result_template
      "/career_tests/results/talent_feedback/shou"
    end
    
    def side_template
      nil
    end
    
  end

end
