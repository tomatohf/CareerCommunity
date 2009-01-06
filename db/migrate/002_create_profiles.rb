class CreateProfiles < ActiveRecord::Migration
  def self.up
    
    # provinces table
    create_table :provinces, :force => true do |t|
      t.column :name, :string
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :provinces, :delta
    
    # cities table
    create_table :cities, :force => true do |t|
      t.column :name, :string
      t.column :province_id, :integer
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :cities, :delta
    
    
    
    # basic_profiles table
    create_table :basic_profiles, :force => true do |t|
      t.column :account_id, :integer
      t.column :updated_at, :datetime
      
      t.column :real_name, :string, :limit => 50
      
      t.column :gender, :boolean

      t.column :province_id, :integer
      t.column :city_id, :integer
      
      t.column :hometown_province_id, :integer
      t.column :hometown_city_id, :integer
      
      t.column :birthday, :date
      
      t.column :qmd, :string, :limit => 300
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :basic_profiles, :account_id
    add_index :basic_profiles, :birthday
    add_index :basic_profiles, :real_name
    add_index :basic_profiles, :province_id
    add_index :basic_profiles, :city_id
    add_index :basic_profiles, :hometown_province_id
    add_index :basic_profiles, :hometown_city_id
    add_index :basic_profiles, :delta
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO basic_profiles (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM basic_profiles WHERE id = 1000")
    
    # contact_profiles table
    create_table :contact_profiles, :force => true do |t|
      t.column :account_id, :integer
      t.column :updated_at, :datetime
      
      t.column :msn, :string
      t.column :gtalk, :string
      
      t.column :qq, :string, :limit => 20
      
      t.column :skype, :string
      
      t.column :mobile, :string, :limit => 25
      t.column :phone, :string, :limit => 25
      
      t.column :address, :string
      t.column :website, :string
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :contact_profiles, :account_id
    add_index :contact_profiles, :delta
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO contact_profiles (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM contact_profiles WHERE id = 1000")
    
    # hobby_profiles table
    create_table :hobby_profiles, :force => true do |t|
      t.column :account_id, :integer
      t.column :updated_at, :datetime
      
      t.column :intro, :string, :limit => 1000
      t.column :interest, :string, :limit => 1000
      t.column :music, :string, :limit => 1000
      t.column :movie, :string, :limit => 1000
      t.column :cartoon, :string, :limit => 1000
      t.column :game, :string, :limit => 1000
      t.column :sport, :string, :limit => 1000
      t.column :book, :string, :limit => 1000
      t.column :words, :string, :limit => 1000
      t.column :food, :string, :limit => 1000
      t.column :idol, :string, :limit => 1000
      t.column :car, :string, :limit => 1000
      t.column :place, :string, :limit => 1000
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :hobby_profiles, :account_id
    add_index :hobby_profiles, :delta
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO hobby_profiles (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM hobby_profiles WHERE id = 1000")
    
    # education_profiles table
    create_table :education_profiles, :force => true do |t|
      t.column :account_id, :integer
      t.column :updated_at, :datetime
      
      t.column :education_id, :integer, :limit => 1
      t.column :enter_year, :integer, :limit => 2

      t.column :edu_name, :string
      t.column :major, :string
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :education_profiles, :account_id
    add_index :education_profiles, :education_id
    add_index :education_profiles, :enter_year
    add_index :education_profiles, :delta
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO education_profiles (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM education_profiles WHERE id = 1000")
    
    # job_profiles table
    create_table :job_profiles, :force => true do |t|
      t.column :account_id, :integer
      t.column :updated_at, :datetime
      
      t.column :profession_id, :integer, :limit => 1
      t.column :enter_year, :integer, :limit => 2
      t.column :enter_month, :integer, :limit => 1
      
      t.column :job_name, :string
      t.column :dept, :string
      t.column :position_title, :string
      t.column :description, :string, :limit => 1000
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :job_profiles, :account_id
    add_index :job_profiles, :profession_id
    add_index :job_profiles, :enter_year
    add_index :job_profiles, :enter_month
    add_index :job_profiles, :delta
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO job_profiles (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM job_profiles WHERE id = 1000")
    
    
    
    # point_profiles table
    create_table :point_profiles, :force => true do |t|
      t.column :account_id, :integer
      t.column :updated_at, :datetime
      
      t.column :points, :integer
      t.column :exp, :integer
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :point_profiles, :account_id
    add_index :point_profiles, :points
    add_index :point_profiles, :exp
    add_index :point_profiles, :delta
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO point_profiles (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM point_profiles WHERE id = 1000")
    
    
    
    # pic_profiles table
    create_table :pic_profiles, :force => true do |t|
      t.column :account_id, :integer
      t.column :updated_at, :datetime
      
      t.column :photo_id, :integer
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :pic_profiles, :account_id
    add_index :pic_profiles, :photo_id
    add_index :pic_profiles, :delta
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO pic_profiles (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM pic_profiles WHERE id = 1000")
    
    
    

    
    # initialize the provices & cities
    province = Province.new :name => "北京"
    province.save!
    ["东城",
    "西城",
    "崇文",
    "宣武",
    "朝阳",
    "丰台",
    "石景山",
    "海淀",
    "门头沟",
    "房山",
    "通州",
    "顺义",
    "昌平",
    "大兴",
    "平谷",
    "怀柔",
    "密云",
    "延庆"].each do |c|
      city = City.new :name => c, :province_id => province.id
      city.save!
    end
    
    province = Province.new :name => "上海"
    province.save!
    ["崇明",
    "黄浦",
    "卢湾",
    "徐汇",
    "长宁",
    "静安",
    "普陀",
    "闸北",
    "虹口",
    "杨浦",
    "闵行",
    "宝山",
    "嘉定",
    "浦东",
    "金山",
    "松江",
    "青浦",
    "南汇",
    "奉贤"].each do |c|
      city = City.new :name => c, :province_id => province.id
      city.save!
    end
    
    province = Province.new :name => "重庆"
    province.save!
    ["万州",
    "涪陵",
    "渝中",
    "大渡口",
    "江北",
    "沙坪坝",
    "九龙坡",
    "南岸",
    "北碚",
    "万盛",
    "双挢",
    "渝北",
    "巴南",
    "黔江",
    "长寿",
    "綦江",
    "潼南",
    "铜梁",
    "大足",
    "荣昌",
    "壁山",
    "梁平",
    "城口",
    "丰都",
    "垫江",
    "武隆",
    "忠县",
    "开县",
    "云阳",
    "奉节",
    "巫山",
    "巫溪",
    "石柱",
    "秀山",
    "酉阳",
    "彭水",
    "江津",
    "合川",
    "永川",
    "南川"].each do |c|
      city = City.new :name => c, :province_id => province.id
      city.save!
    end
    
    province = Province.new :name => "天津"
    province.save!
    ["和平",
    "东丽",
    "河东",
    "西青",
    "河西",
    "津南",
    "南开",
    "北辰",
    "河北",
    "武清",
    "红挢",
    "塘沽",
    "汉沽",
    "大港",
    "宁河",
    "静海",
    "宝坻",
    "蓟县"].each do |c|
      city = City.new :name => c, :province_id => province.id
      city.save!
    end
    
    province = Province.new :name => "安徽"
    province.save!
    ["合肥",
    "安庆",
    "蚌埠",
    "亳州",
    "巢湖",
    "滁州",
    "阜阳",
    "贵池",
    "淮北",
    "淮化",
    "淮南",
    "黄山",
    "九华山",
    "六安",
    "马鞍山",
    "宿州",
    "铜陵",
    "屯溪",
    "芜湖",
    "宣城"].each do |c|
      city = City.new :name => c, :province_id => province.id
      city.save!
    end
    
    province = Province.new :name => "福建"
    province.save!
    ["福州",
    "福安",
    "龙岩",
    "南平",
    "宁德",
    "莆田",
    "泉州",
    "三明",
    "邵武",
    "石狮",
    "永安",
    "武夷山",
    "厦门",
    "漳州"].each do |c|
      city = City.new :name => c, :province_id => province.id
      city.save!
    end
    
    province = Province.new :name => "甘肃"
    province.save!
    ["兰州",
    "白银",
    "定西",
    "敦煌",
    "甘南",
    "金昌",
    "酒泉",
    "临夏",
    "平凉",
    "天水",
    "武都",
    "武威",
    "西峰",
    "张掖"].each do |c|
      city = City.new :name => c, :province_id => province.id
      city.save!
    end
    
    province = Province.new :name => "广东"
    province.save!
    ["广州",
    "潮阳",
    "潮州",
    "澄海",
    "东莞",
    "佛山",
    "河源",
    "惠州",
    "江门",
    "揭阳",
    "开平",
    "茂名",
    "梅州",
    "清远",
    "汕头",
    "汕尾",
    "韶关",
    "深圳",
    "顺德",
    "阳江",
    "英德",
    "云浮",
    "增城",
    "湛江",
    "肇庆",
    "中山",
    "珠海"].each do |c|
      city = City.new :name => c, :province_id => province.id
      city.save!
    end
    
    province = Province.new :name => "广西"
    province.save!
    ["南宁",
    "百色",
    "北海",
    "桂林",
    "防城港",
    "河池",
    "贺州",
    "柳州",
    "钦州",
    "梧州",
    "玉林"].each do |c|
      city = City.new :name => c, :province_id => province.id
      city.save!
    end
    
    province = Province.new :name => "贵州"
    province.save!
    ["贵阳",
    "安顺",
    "毕节",
    "都匀",
    "凯里",
    "六盘水",
    "铜仁",
    "兴义",
    "玉屏",
    "遵义"].each do |c|
      city = City.new :name => c, :province_id => province.id
      city.save!
    end
    
    province = Province.new :name => "海南"
    province.save!
    ["海口",
    "儋县",
    "陵水",
    "琼海",
    "三亚",
    "通什",
    "万宁"].each do |c|
      city = City.new :name => c, :province_id => province.id
      city.save!
    end
    
    province = Province.new :name => "河北"
    province.save!
    ["石家庄",
    "保定",
    "北戴河",
    "沧州",
    "承德",
    "丰润",
    "邯郸",
    "衡水",
    "廊坊",
    "南戴河",
    "秦皇岛",
    "唐山",
    "新城",
    "邢台",
    "张家口"].each do |c|
      city = City.new :name => c, :province_id => province.id
      city.save!
    end
    
    province = Province.new :name => "黑龙江"
    province.save!
    ["哈尔滨",
    "北安",
    "大庆",
    "大兴安岭",
    "鹤岗",
    "黑河",
    "佳木斯",
    "鸡西",
    "牡丹江",
    "齐齐哈尔",
    "七台河",
    "双鸭山",
    "绥化",
    "伊春"].each do |c|
      city = City.new :name => c, :province_id => province.id
      city.save!
    end
    
    province = Province.new :name => "河南"
    province.save!
    ["郑州",
    "安阳",
    "鹤壁",
    "潢川",
    "焦作",
    "济源",
    "开封",
    "漯河",
    "洛阳",
    "南阳",
    "平顶山",
    "濮阳",
    "三门峡",
    "商丘",
    "新乡",
    "信阳",
    "许昌",
    "周口",
    "驻马店"].each do |c|
      city = City.new :name => c, :province_id => province.id
      city.save!
    end
    
    province = Province.new :name => "湖北"
    province.save!
    ["武汉",
    "恩施",
    "鄂州",
    "黄冈",
    "黄石",
    "荆门",
    "荆州",
    "潜江",
    "十堰",
    "随州",
    "武穴",
    "仙桃",
    "咸宁",
    "襄阳",
    "襄樊",
    "孝感",
    "宜昌"].each do |c|
      city = City.new :name => c, :province_id => province.id
      city.save!
    end
    
    province = Province.new :name => "湖南"
    province.save!
    ["长沙",
    "常德",
    "郴州",
    "衡阳",
    "怀化",
    "吉首",
    "娄底",
    "邵阳",
    "湘潭",
    "益阳",
    "岳阳",
    "永州",
    "张家界",
    "株洲"].each do |c|
      city = City.new :name => c, :province_id => province.id
      city.save!
    end
    
    province = Province.new :name => "江苏"
    province.save!
    ["南京",
    "常熟",
    "常州",
    "海门",
    "淮安",
    "江都",
    "江阴",
    "昆山",
    "连云港",
    "南通",
    "启东",
    "沭阳",
    "宿迁",
    "苏州",
    "太仓",
    "泰州",
    "同里",
    "无锡",
    "徐州",
    "盐城",
    "扬州",
    "宜兴",
    "仪征",
    "张家港",
    "镇江",
    "周庄"].each do |c|
      city = City.new :name => c, :province_id => province.id
      city.save!
    end
    
    province = Province.new :name => "江西"
    province.save!
    ["南昌",
    "抚州",
    "赣州",
    "吉安",
    "景德镇",
    "井冈山",
    "九江",
    "庐山",
    "萍乡",
    "上饶",
    "新余",
    "宜春",
    "鹰潭"].each do |c|
      city = City.new :name => c, :province_id => province.id
      city.save!
    end
    
    province = Province.new :name => "吉林"
    province.save!
    ["长春",
    "白城",
    "白山",
    "珲春",
    "辽源",
    "梅河",
    "吉林",
    "四平",
    "松原",
    "通化",
    "延吉"].each do |c|
      city = City.new :name => c, :province_id => province.id
      city.save!
    end
    
    province = Province.new :name => "辽宁"
    province.save!
    ["沈阳",
    "鞍山",
    "本溪",
    "朝阳",
    "大连",
    "丹东",
    "抚顺",
    "阜新",
    "葫芦岛",
    "锦州",
    "辽阳",
    "盘锦",
    "铁岭",
    "营口"].each do |c|
      city = City.new :name => c, :province_id => province.id
      city.save!
    end
    
    province = Province.new :name => "内蒙古"
    province.save!
    ["呼和浩特",
    "阿拉善盟",
    "包头",
    "赤峰",
    "东胜",
    "海拉尔",
    "集宁",
    "临河",
    "通辽",
    "乌海",
    "乌兰浩特",
    "锡林浩特"].each do |c|
      city = City.new :name => c, :province_id => province.id
      city.save!
    end
    
    province = Province.new :name => "宁夏"
    province.save!
    ["银川",
    "固源",
    "石嘴山",
    "吴忠"].each do |c|
      city = City.new :name => c, :province_id => province.id
      city.save!
    end
    
    province = Province.new :name => "青海"
    province.save!
    ["西宁",
    "德令哈",
    "格尔木",
    "共和",
    "海东",
    "海晏",
    "玛沁",
    "同仁",
    "玉树"].each do |c|
      city = City.new :name => c, :province_id => province.id
      city.save!
    end
    
    province = Province.new :name => "山东"
    province.save!
    ["济南",
    "滨州",
    "兖州",
    "德州",
    "东营",
    "菏泽",
    "济宁",
    "莱芜",
    "聊城",
    "临沂",
    "蓬莱",
    "青岛",
    "曲阜",
    "日照",
    "泰安",
    "潍坊",
    "威海",
    "烟台",
    "枣庄",
    "淄博"].each do |c|
      city = City.new :name => c, :province_id => province.id
      city.save!
    end
    
    province = Province.new :name => "山西"
    province.save!
    ["太原",
    "长治",
    "大同",
    "候马",
    "晋城",
    "离石",
    "临汾",
    "宁武",
    "朔州",
    "忻州",
    "阳泉",
    "晋中",
    "运城"].each do |c|
      city = City.new :name => c, :province_id => province.id
      city.save!
    end
    
    province = Province.new :name => "陕西"
    province.save!
    ["西安",
    "安康",
    "宝鸡",
    "汉中",
    "渭南",
    "商州",
    "绥德",
    "铜川",
    "咸阳",
    "延安",
    "榆林"].each do |c|
      city = City.new :name => c, :province_id => province.id
      city.save!
    end
    
    province = Province.new :name => "四川"
    province.save!
    ["成都", "成都",
    "巴中",
    "达川",
    "德阳",
    "都江堰",
    "峨眉山",
    "涪陵",
    "广安",
    "广元",
    "九寨沟",
    "康定",
    "乐山",
    "泸州",
    "马尔康",
    "绵阳",
    "眉山",
    "南充",
    "内江",
    "攀枝花",
    "遂宁",
    "汶川",
    "西昌",
    "雅安",
    "宜宾",
    "自贡",
    "资阳"].each do |c|
      city = City.new :name => c, :province_id => province.id
      city.save!
    end
    
    province = Province.new :name => "新疆"
    province.save!
    ["乌鲁木齐",
    "阿克苏",
    "阿勒泰",
    "阿图什",
    "博乐",
    "昌吉",
    "东山",
    "哈密",
    "和田",
    "喀什",
    "克拉玛依",
    "库车",
    "库尔勒",
    "奎屯",
    "石河子",
    "塔城",
    "吐鲁番",
    "伊宁"].each do |c|
      city = City.new :name => c, :province_id => province.id
      city.save!
    end
    
    province = Province.new :name => "西藏"
    province.save!
    ["拉萨",
    "阿里",
    "昌都",
    "林芝",
    "那曲",
    "日喀则",
    "山南"].each do |c|
      city = City.new :name => c, :province_id => province.id
      city.save!
    end
    
    province = Province.new :name => "云南"
    province.save!
    ["昆明",
    "大理",
    "保山",
    "楚雄",
    "大理",
    "东川",
    "个旧",
    "景洪",
    "开远",
    "临沧",
    "丽江",
    "六库",
    "潞西",
    "曲靖",
    "思茅",
    "文山",
    "西双版纳",
    "玉溪",
    "中甸",
    "昭通"].each do |c|
      city = City.new :name => c, :province_id => province.id
      city.save!
    end
    
    province = Province.new :name => "浙江"
    province.save!
    ["杭州",
    "安吉",
    "慈溪",
    "定海",
    "奉化",
    "海盐",
    "黄岩",
    "湖州",
    "嘉兴",
    "金华",
    "临安",
    "临海",
    "丽水",
    "宁波",
    "瓯海",
    "平湖",
    "千岛湖",
    "衢州",
    "江山",
    "瑞安",
    "绍兴",
    "嵊州",
    "台州",
    "温岭",
    "温州",
    "余姚",
    "舟山"].each do |c|
      city = City.new :name => c, :province_id => province.id
      city.save!
    end
    
    province = Province.new :name => "香港"
    province.save!
    ["香港",
    "九龙",
    "新界"].each do |c|
      city = City.new :name => c, :province_id => province.id
      city.save!
    end
    
    province = Province.new :name => "澳门"
    province.save!
    ["澳门"].each do |c|
      city = City.new :name => c, :province_id => province.id
      city.save!
    end
    
    province = Province.new :name => "台湾"
    province.save!
    ["台北",
    "基隆",
    "台南",
    "台中",
    "高雄",
    "屏东",
    "南投",
    "云林",
    "新竹",
    "彰化",
    "苗栗",
    "嘉义",
    "花莲",
    "桃园",
    "宜兰",
    "台东",
    "金门",
    "马祖",
    "澎湖"].each do |c|
      city = City.new :name => c, :province_id => province.id
      city.save!
    end
    
    province = Province.new :name => "海外"
    province.save!
    ["欧洲",
    "北美",
    "南美",
    "亚洲",
    "非洲",
    "大洋洲"].each do |c|
      city = City.new :name => c, :province_id => province.id
      city.save!
    end
    
  end

  def self.down
    drop_table :pic_profiles
    drop_table :point_profiles
    drop_table :job_profiles
    drop_table :education_profiles
    drop_table :hobby_profiles
    drop_table :contact_profiles
    drop_table :basic_profiles
    drop_table :cities
    drop_table :provinces
  end
end
