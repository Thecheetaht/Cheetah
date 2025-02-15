require 'lib.cheetah'
require 'lib.lquery.init'
require 'lib.gl'

local C = cheetah
C.init('Blend modes', '1024x512 vsync')

local gray = C.generate('light', 64, 64)
local img = C.newImage('sprite.png')
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
	C.color(0,0,0,0)
	--~ C.blendEquation(cheetah.GL_FUNC_REVERSE_SUBTRACT)
	--~ C.texEnv(C.GL_TEXTURE_ENV, C.GL_SRC0_RGB, C.GL_CONSTANT)
	for i, u in ipairs(blend1) do
		for j, v in ipairs(blend2) do
			C.blendFunc(u, v)
			img:draw((i-1)*64, (j-1)*64)
		end
	end
	for i, u in ipairs(blend1) do
		for j, v in ipairs(blend2) do
			C.blendFunc(u, v)
			gray:draw((i+8)*64, (j-1)*64)
		end
	end
	C.color(255,255,255,255)
	C.blendEquation(cheetah.GL_FUNC_ADD)
	C.blendMode(0)
end)

C.mainLoop()
