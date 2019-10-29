waxClass{"MyViewController",UIViewController}

function init(self)
  self.super:init()
  --设置title
  self:setTitle("纯lua的controller")
  return self
end

function viewDidLoad(self)
self.super:viewDidLoad(self)
  self:view():setBackgroundColor(UIColor:yellowColor())
  btn = UIButton:initWithFrame(CGRect(300,100,60,30))
  btn:setTitle_forState("dismiss",UIControlStateNormal)
  btn:addTarget_action_forControlEvents(self,"dismiss:",UIControlEventTouchUpInside)
  btn:setTitleColor_forState(UIColor:blackColor(),UIControlStateNormal)
  self:view():addSubview(btn)
  
end

function dismiss(self,sender)
self:dismissViewControllerAnimated_completion(true,nil)
end
