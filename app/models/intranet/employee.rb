module Intranet
  class Employee < StaticModel::HashBase
  
    def self.data
      [
        {:id => 20, :name => "马晓", :account_id => 1002, :manager => true, :email => "rick@"},
        {:id => 30, :name => "沈锴", :account_id => 1019, :manager => true, :email => "shenkai@"},
        
        {:id => 40, :name => "顾艳", :account_id => 1422, :manager => false, :email => "guyan@woshiyanzijie"},
        # {:id => 50, :name => "陈松凤", :account_id => 6401, :manager => false, :email => "debbychen@36915105"},
        # {:id => 70, :name => "王佳俊", :account_id => 6398, :manager => false, :email => "leowang@80525361"},
        {:id => 80, :name => "张杰", :account_id => 1074, :manager => false, :email => "zhangjie@iamzj"},
        {:id => 90, :name => "刘偲", :account_id => 6616, :manager => false, :email => "liucai@liuc@i"},
        {:id => 100, :name => "陆洁扬", :account_id => 6887, :manager => false, :email => "lujieyang@lujieyang1103"},
        
        {:id => 110, :name => "汪刘益", :account_id => 7114, :manager => false, :email => "wangliuyi@609234989"},
        {:id => 120, :name => "刘鹤鸣", :account_id => 7292, :manager => false, :email => "liuheming@raulgood"},
        {:id => 130, :name => "陆圆", :account_id => 7317, :manager => false, :email => "luyuan@900103"},
        # {:id => 140, :name => "方旭东", :account_id => , :manager => false, :email => "fangxudong@0874018"},
        # {:id => 150, :name => "沙宏刚", :account_id => , :manager => false, :email => "shahonggang@xiaosha"},
        # {:id => 160, :name => "刘玥佩", :account_id => , :manager => false, :email => "liuyuepei@04211123"},
        # {:id => 170, :name => "秦涛", :account_id => , :manager => false, :email => "qintao@qt0720"},
        # {:id => 180, :name => "张斌", :account_id => , :manager => false, :email => "zhangbin@wstc0714"},
        # {:id => 190, :name => "夏迪", :account_id => , :manager => false, :email => "xiadi@xiadi"},
        # {:id => 200, :name => "朱岚", :account_id => , :manager => false, :email => "zhulan@19881215"},
        # {:id => 210, :name => "陈骥君", :account_id => , :manager => false, :email => "chenjijun@65897129"},
        {:id => 220, :name => "裔传洁", :account_id => 7960, :manager => false, :email => "yichuanjie@7758258"},
        # {:id => 230, :name => "陈颖川", :account_id => , :manager => false, :email => "chenyingchuan@chuan1314"},
        # {:id => 240, :name => "严晓丹", :account_id => , :manager => false, :email => "yanxiaodan@2wsx3edc"},
        {:id => 250, :name => "杜肖锋", :account_id => 7962, :manager => false, :email => "duxiaofeng@592617331"},
        {:id => 260, :name => "杨汝宸", :account_id => 7961, :manager => false, :email => "yangruchen@yangruchen"},
        
        {:id => 10, :name => "何帆", :account_id => 1001, :manager => true, :email => "hefan@"}
      ]
    end
  
  end
end
