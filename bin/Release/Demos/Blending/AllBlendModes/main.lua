require 'lib.cheetah'
require 'lib.lquery.init'
local C = cheetah
C.init('Test', 1024, 512+64, 32, 'v')
C.printFPS = true
local img = C.generate('light', 32, 32)
local img1 = C.newImage('sprite.png')
lQuery.addhook(C.clear)
E:new(screen):image('brick.jpg')
:size(1024, 1024)
local blend1 = {
	cheetah.GL_ZERO,
	cheetah.GL_ONE,
	cheetah.GL_DST_COLOR,
	cheetah.GL_ONE_MINUS_DST_COLOR,
	cheetah.GL_SRC_ALPHA,
	cheetah.GL_ONE_MINUS_SRC_ALPHA,
	cheetah.GL_DST_ALPHA,
	cheetah.GL_ONE_MINUS_DST_ALPHA,
	cheetah.GL_SRC_ALPHA_SATURATE
}
local blend2 = {
	cheetah.GL_ZERO,
	cheetah.GL_ONE,
	cheetah.GL_SRC_COLOR,
	cheetah.GL_ONE_MINUS_SRC_COLOR,
	cheetah.GL_SRC_ALPHA,
	cheetah.GL_ONE_MINUS_SRC_ALPHA,
	cheetah.GL_DST_ALPHA,
	cheetah.GL_ONE_MINUS_DST_ALPHA
}
E:new(screen):draw(function()
	C.move(0, 0)
	C.color(255,255,255,255)
	--~ C.setBlendEquation(cheetah.GL_MAX)
	
	for i, u in ipairs(blend1) do
		C.push()
		for j, v in ipairs(blend2) do
			C.blendFunc(u, v)
			--~ C.setBlendMode(C.blendMask)
			
			img1:draw()
			C.move(1, 0)
		end
		C.pop()
		C.move(0, 1)
	end
	C.move(8, -9)
	for i, u in ipairs(blend1) do
		C.push()
		for j, v in ipairs(blend2) do
			C.blendFunc(u, v)
			img:draw()
			C.move(1, 0)
		end
		C.pop()
		C.move(0, 1)
	end
	C.blendEquation(cheetah.GL_FUNC_ADD)
	C.blendMode(0)
end):size(64, 64):translate()

C.mainLoop()