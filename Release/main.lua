------------ THIS IS THE SAMPLE APPLICATION FOR CHEETAH 2D ENGINE --------------

require 'lib.cheetah'
--~ require 'lib.mixer'
require 'lib.lquery.init'
local C = cheetah
C.init('Welcome to Cheetah 2D Engine!', 'fullscreen vsync')
Entity:new(screen)
:image('Cheetahs.jpg')
:move(-800,0)
:delay(0.5)
:animate({x = 0})
:draggable()

--~ C.playMusic('Demos/Sound/Music/Stars.ogg')

C.mainLoop()