require("MyViewController")
waxClass{"ViewController",UIViewController}

function viewDidLoad(self)
self:ORIGviewDidLoad(self)
self:view():setBackgroundColor(UIColor:redColor())
btn = UIButton:initWithFrame(CGRect(20,100,60,30))
btn:setTitle_forState("testBtn",UIControlStateNormal)
btn:addTarget_action_forControlEvents(self,"jumpToNextPage:",UIControlEventTouchUpInside)
self:view():addSubview(btn)
end

function jumpToNextPage(self,sender)
local myV = MyViewController:alloc():init()
self:presentViewController_animated_completion(myV,true,nil)
--self:navigationController():pushViewController_animated(myV, true)
end
