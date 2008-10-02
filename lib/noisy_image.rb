class NoisyImage
  include Magick
  
  attr_reader :code, :code_image
  Jiggle = 15
  Wobble = 15
  
  def initialize(len, color="orange", bg_color="xc:#FFF5E8")
    chars = ("a".."z").to_a - ["a","e","i","o","u"]
    code_array=[]
    1.upto(len) { code_array << chars[rand(chars.length)] }
    
    # background_type = "granite:" # 花岗岩
    # background_type = "netscape:" # 彩条
    # background_type = "logo:" # logo型的图像. 如: "logo:"，后面会多显示一个五角星
    # background_type = "rose:" # 玫瑰 使用方式 : "rose:"
    # background_type = "xc:#EDF7E7" # 指定背景色, 例：xc:red
    background_type = bg_color
    # background_type = "null:" # 纯黑
    
    granite = Magick::ImageList.new(background_type)
    canvas = Magick::ImageList.new
    canvas.new_image(32 * len, 50, Magick::TextureFill.new(granite))
    text = Magick::Draw.new
    text.font_family = "times"
    text.pointsize = 40
    cur = 10
    
    code_array.each { |c|
      rand(10) > 5 ? rot = rand(Wobble) : rot = -rand(Wobble)
      rand(10) > 5 ? weight = NormalWeight : weight = BoldWeight
      text.annotate(canvas, 0, 0, cur, 30 + rand(Jiggle), c) {
        self.rotation = rot
        self.font_weight = weight
        self.fill = color
      }
      cur += 30
    }
    @code = code_array.to_s
    @code_image = canvas.to_blob{
      self.format="jpg"
    }
  end
  
end