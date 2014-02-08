--[[****************************************************************************

Copyright (c) 2012 Pavel Roschin (aka RPG) <rpg89@post.ru>

Permission is hereby granted, free of charge, to any person obtaining a copy 
of this software and associated documentation files (the "Software"), to 
deal in the Software without restriction, including without limitation the 
rights to use, copy, modify, merge, publish, distribute, sublicense, and/or 
sell copies of the Software, and to permit persons to whom the Software is 
furnished to do so, subject to the following conditions:  The above 
copyright notice and this permission notice shall be included in all copies 
or substantial portions of the Software.
 
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS 
IN THE SOFTWARE.

******************************************************************************]]

local ffi = require 'ffi'
local chipmunk = cheetah.loadDLL 'chipmunk'
local cp = {
	--~ v = chipmunk.v,
}
cp.vzero = ffi.new('cpVect', {0,0})

--OOP definitions

ffi.metatype('cpBody', {
	__index = {
		init = chipmunk.BodyInit,
		initStatic = chipmunk.BodyInitStatic,
		newStatic = chipmunk.BodyNewStatic,
		destroy = chipmunk.BodyDestroy,
		sanityCheck = cpBodySanityCheck,
		activate = chipmunk.BodyActivate,
		activateStatic = chipmunk.BodyActivateStatic,
		sleep = chipmunk.BodySleep,
		sleepWithGroup = chipmunk.BodySleepWithGroup,
		isSleeping = chipmunk.BodyIsSleeping,
		isStatic = chipmunk.BodyIsStatic,
		isRogue = chipmunk.BodyIsRogue,
		getMass = chipmunk.BodyGetMass,
		setMass = chipmunk.BodySetMass,
		getMoment = chipmunk.BodyGetMoment,
		setMoment = chipmunk.BodySetMoment,
		getPos = chipmunk.BodyGetPos,
		setPos = chipmunk.BodySetPos,
		getVel = chipmunk.BodyGetVel,
		setVel = chipmunk.BodySetVel,
		getForce = chipmunk.BodyGetForce,
		setForce = chipmunk.BodySetForce,
		getAngle = chipmunk.BodyGetAngle,
		setAngle = chipmunk.BodySetAngle,
		getAngVel = chipmunk.BodyGetAngVel,
		setAngVel = chipmunk.BodySetAngVel,
		getTorque = chipmunk.BodyGetTorque,
		setTorque = chipmunk.BodySetTorque,
		getRot = chipmunk.BodyGetRot,
		getVelLimit = chipmunk.BodyGetVelLimit,
		setVelLimit = chipmunk.BodySetVelLimit,
		getAngVelLimit = chipmunk.BodyGetAngVelLimit,
		setAngVelLimit = chipmunk.BodySetAngVelLimit,
		getUserData = chipmunk.BodyGetUserData,
		setUserData = chipmunk.BodySetUserData,
		updateVelocity = chipmunk.BodyUpdateVelocity,
		updatePosition = chipmunk.BodyUpdatePosition,
		local2World = chipmunk.BodyLocal2World,
		world2Local = chipmunk.BodyWorld2Local,
		resetForces = chipmunk.BodyResetForces,
		applyForce = chipmunk.BodyApplyForce,
		applyImpulse = chipmunk.BodyApplyImpulse,
		getVelAtWorldPoint = chipmunk.BodyGetVelAtWorldPoint,
		getVelAtLocalPoint = chipmunk.BodyGetVelAtLocalPoint,
	},
	__gc = chipmunk.BodyFree
})

ffi.metatype('cpShape', {
	__index = {
		destroy = chipmunk.ShapeDestroy,
		cacheBB = chipmunk.ShapeCacheBB,
		update = chipmunk.ShapeUpdate,
		pointQuery = chipmunk.ShapePointQuery,
		getBody = chipmunk.ShapeGetBody,
		setBody = chipmunk.ShapeSetBody,
		getBB = chipmunk.ShapeGetBB,
		getSensor = chipmunk.ShapeGetSensor,
		setSensor = chipmunk.ShapeSetSensor,
		getElasticity = chipmunk.ShapeGetElasticity,
		setElasticity = chipmunk.ShapeSetElasticity,
		getFriction = chipmunk.ShapeGetFriction,
		setFriction = chipmunk.ShapeSetFriction,
		getSurfaceVelocity = chipmunk.ShapeGetSurfaceVelocity,
		setSurfaceVelocity = chipmunk.ShapeSetSurfaceVelocity,
		getUserData = chipmunk.ShapeGetUserData,
		setUserData = chipmunk.ShapeSetUserData,
		getCollisionType = chipmunk.ShapeGetCollisionType,
		setCollisionType = chipmunk.ShapeSetCollisionType,
		getGroup = chipmunk.ShapeGetGroup,
		setGroup = chipmunk.ShapeSetGroup,
		getLayers = chipmunk.ShapeGetLayers,
		setLayers = chipmunk.ShapeSetLayers,
		segmentQuery = chipmunk.ShapeSegmentQuery,
	},
	__gc = chipmunk.ShapeFree
})

ffi.metatype('cpSpace', {
	__index = {
		destroy = chipmunk.SpaceDestroy,
		getIterations = chipmunk.SpaceGetIterations,
		setIterations = chipmunk.SpaceSetIterations,
		getGravity = chipmunk.SpaceGetGravity,
		setGravity = chipmunk.SpaceSetGravity,
		getDamping = chipmunk.SpaceGetDamping,
		setDamping = chipmunk.SpaceSetDamping,
		getIdleSpeedThreshold = chipmunk.SpaceGetIdleSpeedThreshold,
		setIdleSpeedThreshold = chipmunk.SpaceSetIdleSpeedThreshold,
		getSleepTimeThreshold = chipmunk.SpaceGetSleepTimeThreshold,
		setSleepTimeThreshold = chipmunk.SpaceSetSleepTimeThreshold,
		getCollisionSlop = chipmunk.SpaceGetCollisionSlop,
		setCollisionSlop = chipmunk.SpaceSetCollisionSlop,
		getCollisionBias = chipmunk.SpaceGetCollisionBias,
		setCollisionBias = chipmunk.SpaceSetCollisionBias,
		getCollisionPersistence = chipmunk.SpaceGetCollisionPersistence,
		setCollisionPersistence = chipmunk.SpaceSetCollisionPersistence,
		getEnableContactGraph = chipmunk.SpaceGetEnableContactGraph,
		setEnableContactGraph = chipmunk.SpaceSetEnableContactGraph,
		getUserData = chipmunk.SpaceGetUserData,
		setUserData = chipmunk.SpaceSetUserData,
		getStaticBody = chipmunk.SpaceGetStaticBody,
		getCurrentTimeStep = chipmunk.SpaceGetCurrentTimeStep,
		isLocked = chipmunk.SpaceIsLocked,
		removeCollisionHandler = chipmunk.SpaceRemoveCollisionHandler,
		addShape = chipmunk.SpaceAddShape,
		addStaticShape = chipmunk.SpaceAddStaticShape,
		addBody = chipmunk.SpaceAddBody,
		addConstraint = chipmunk.SpaceAddConstraint,
		removeShape = chipmunk.SpaceRemoveShape,
		removeStaticShape = chipmunk.SpaceRemoveStaticShape,
		removeBody = chipmunk.SpaceRemoveBody,
		removeConstraint = chipmunk.SpaceRemoveConstraint,
		containsShape = chipmunk.SpaceContainsShape,
		containsBody = chipmunk.SpaceContainsBody,
		containsConstraint = chipmunk.SpaceContainsConstraint,
		addPostStepCallback = chipmunk.SpaceAddPostStepCallback,
		pointQuery = chipmunk.SpacePointQuery,
		pointQueryFirst = chipmunk.SpacePointQueryFirst,
		segmentQuery = chipmunk.SpaceSegmentQuery,
		segmentQueryFirst = chipmunk.SpaceSegmentQueryFirst,
		bBQuery = chipmunk.SpaceBBQuery,
		shapeQuery = chipmunk.SpaceShapeQuery,
		activateShapesTouchingShape = chipmunk.SpaceActivateShapesTouchingShape,
		eachBody = chipmunk.SpaceEachBody,
		eachShape = chipmunk.SpaceEachShape,
		eachConstraint = chipmunk.SpaceEachConstraint,
		reindexStatic = chipmunk.SpaceReindexStatic,
		reindexShape = chipmunk.SpaceReindexShape,
		reindexShapesForBody = chipmunk.SpaceReindexShapesForBody,
		useSpatialHash = chipmunk.SpaceUseSpatialHash,
		step = chipmunk.SpaceStep,
		addCollisionHandler = chipmunk.spaceAddCollisionHandler,
	},
	__gc = chipmunk.SpaceFree
})

local C = cheetah
local mouseBody, mouseJoint, mouseShape, mPoint

local maxMouseForce = 50000

cp.mouseForce = function(v)
	maxMouseForce = v or 50000
end

local maxStepsPerFrame = 1
cp.stepsPerFrame = function(v)
	maxStepsPerFrame = v or 1
end
cp.defaultScape = function(gravity, steps)
	if lQuery then
		lQuery.addhook(function()
			--fit physics steps inside frames
			for i = 1, maxStepsPerFrame do 
				cp.space:step(1/C.FPS/maxStepsPerFrame)
			end
			mPoint = chipmunk.v(lQuery.mX, lQuery.mY)
			mouseShape = chipmunk.SpacePointQueryFirst(cp.space, mPoint, 1, 1)
			--~ if lQuery.mousePressed then
				local newPoint = cp.vlerp(mouseBody.p, mPoint, 0.25)
				mouseBody.v = cp.vmult(cp.vsub(newPoint, mouseBody.p), 60.0)
				mouseBody.p = newPoint
			--~ end
		end)
	end
	cp.space = chipmunk.SpaceNew()
	cp.space:setGravity(cp.v(0, gravity))
	mouseBody = chipmunk.BodyNew(math.huge, math.huge)
end
local defSpaceErr = 'Init default space before (cp.defaultScape)'
cp.addBorder = function(x1, y1, x2, y2, friction, elasticity)
	assert(cp.space, defSpaceErr)
	local ground = chipmunk.SegmentShapeNew(cp.space.staticBody, chipmunk.v(x1, y1), chipmunk.v(x2, y2), 0)
	ground:setFriction(friction or 0.5)
	ground:setElasticity(elasticity or 0.5)
	cp.space:addShape(ground)
end
cp.addFrame = function(x, y, w, h, friction, elasticity)
	cp.addBorder(x, y, w, y, friction, elasticity) --top
	cp.addBorder(x, h, w, h, friction, elasticity) --bottom
	cp.addBorder(x, y, x, h, friction, elasticity) --left
	cp.addBorder(w, y, w, h, friction, elasticity) --right
end
--lQuery support
if lQuery then
	local physBound = function(s, x, y)
		if C.isPointer(mouseShape) then
			return mouseShape == s.shape
		end
		return false
	end
	local physDraw = function(s)
		local b = s.body
		s.x, s.y, s.angle = b.p.x, b.p.y, b.a
		--~ C.push()
		--~ C.translateObject(b.p.x, b.p.y, b.a * 180 / math.pi, s.w, s.h, s.ox, s.oy)
	end
	--~ local physBodyInit = function(s)
		--~ s.w = 1
		--~ s.h = 1
		--~ s.ox = 0
		--~ s.oy = 0
		--~ s.angle = 0
	--~ end
	local function physEntInt(self, friction, elasticity)
		self.shape:setFriction(friction or 0.5)
		self.shape:setElasticity(elasticity or 0.5)
		self:drawPrepend(physDraw)
		self:bound(physBound)
	end
	function Entity:physCircle(mass, friction, elasticity)
		assert(cp.space, defSpaceErr)
		--~ if radius then self.R = radius end
		assert(self.R, 'Set circle radius (.R or :radius)')
		assert(mass, 'Set circle mass (first argument)')
		--~ physBodyInit(self)
		self.body = cp.space:addBody(chipmunk.BodyNew(mass, chipmunk.MomentForCircle(mass, 0, self.R, cp.vzero)))
		self.body:setPos(chipmunk.v(self.x + self.ox, self.y + self.oy))
		
		self.shape = cp.space:addShape(chipmunk.CircleShapeNew(self.body, self.R, cp.vzero))
		physEntInt(self, friction, elasticity)
		
		return self
	end
	function Entity:physBox(mass, friction, elasticity)
		assert(cp.space, defSpaceErr)
		assert(mass, 'Set box mass (first argument)')
		--~ physBodyInit(self)
		if mass == math.huge then
			self.body = chipmunk.BodyNewStatic()
		else
			self.body = cp.space:addBody(chipmunk.BodyNew(mass, chipmunk.MomentForBox(mass, self.w, self.h)))
		end
		self.body:setPos(chipmunk.v(self.x + self.ox, self.y + self.oy))
		
		if mass == math.huge then
			self.shape = cp.space:addStaticShape(chipmunk.BoxShapeNew(self.body, self.w, self.h))
		else
			self.shape = cp.space:addShape(chipmunk.BoxShapeNew(self.body, self.w, self.h))
		end
		physEntInt(self, friction, elasticity)
		
		return self
	end
	local function physPressed(s)
		if C.isPointer(mouseShape) then
			mouseJoint = chipmunk.PivotJointNew2(mouseBody, mouseShape.body, cp.vzero, chipmunk.BodyWorld2Local(mouseShape.body, mPoint))
			mouseJoint.maxForce = maxMouseForce
			mouseJoint.errorBias = math.pow(1.0 - 0.15, 60.0)
			chipmunk.SpaceAddConstraint(cp.space, mouseJoint)
		end
	end
	local function physReleased(s)
		if C.isPointer(mouseJoint) then 
			chipmunk.SpaceRemoveConstraint(cp.space, mouseJoint);
			chipmunk.ConstraintFree(mouseJoint);
		end
	end
	function Entity:physDraggable()
		assert(cp.space, defSpaceErr)
		self:mousepressed(physPressed)
		self:mousereleased(physReleased)
		return self
	end
end




setmetatable(cp, { __index = chipmunk})
return cp