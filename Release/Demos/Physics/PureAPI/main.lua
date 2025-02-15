require 'lib.cheetah'
require 'lib.lquery.init'
local C = cheetah
--~ C.init('Test', 512, 512, 32, '')
local cp = require 'lib.chipmunk'
space = cp.SpaceNew()
space:setIterations(100)
space:setGravity(cp.v(0, -100))
ground = cp.SegmentShapeNew(space.staticBody, cp.v(-20, 5), cp.v(20, -5), 0)
ground:setFriction(1)
space:addShape(ground)
moment = cp.MomentForCircle(1, 0, 5, cp.vzero)
ballBody = space:addBody(cp.BodyNew(1, moment))
ballBody:setPos(cp.v(0, 15))
ballShape = space:addShape(cp.CircleShapeNew(ballBody, 5, cp.vzero))
ballShape:setFriction(0.7)
for t = 0, 2, 1.0/60.0 do
	pos = ballBody:getPos()
	vel = ballBody:getVel()
	C.printf(
		"Time is %5.2f. ballBody is at (%5.2f, %5.2f). It's velocity is (%5.2f, %5.2f)\n",
		t, pos.x, pos.y, vel.x, vel.y)
	for i = 1, 10000 do
		space:step(1.0/6000.0)
	end
end

