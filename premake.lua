package.name = "cheetah"
package.kind = "dll"
package.language = "c"
package.files = { 
	matchfiles(
		"src/*.h", "src/*.c",
		"src/SOIL/*.h", 
		"src/SOIL/*.c"
		)
}
project.configs = {"Release"}
project.config["Release"].bindir = "bin/Release"
package.buildflags = {"optimize-speed", "no-frame-pointer"}
package.libpaths = {"lib"}
package.includepaths = {
	--~ "thirdparty/LuaJIT/src", 
	"inc"
}
package.links = {"SDL", "GL", --[["luajit",]]}
package.buildoptions = { "-ffast-math -Wall -msse",
--~ " -ftracer -fcx-limited-range -fgcse-las -fgcse-sm -fno-trapping-math -fpeel-loops -fsingle-precision-constant -funsafe-loop-optimizations" 
}
--~ package.buildoptions = { "-ffast-math -mtune=generic -march=core2" }
package.linkoptions = { "-s" }
--~ package.buildoptions = { "-s" }
package.postbuildcommands = {
	"./genheader.sh"
}