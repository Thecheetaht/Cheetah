#!/usr/bin/lua

table.print = function(tt, indent, done)
  done = done or {}
  indent = indent or 0
  if type(tt) == "table" then
    for key, value in pairs (tt) do
      io.write(string.rep (" ", indent)) -- indent it
      if type (value) == "table" and not done [value] then
        done [value] = true
        io.write(string.format("[%s] => table\n", tostring (key)));
        io.write(string.rep (" ", indent+4)) -- indent it
        io.write("(\n");
        table.print (value, indent + 7, done)
        io.write(string.rep (" ", indent+4)) -- indent it
        io.write(")\n");
      else
        io.write(string.format("[%s] => %s\n",
            tostring (key), tostring(value)))
      end
    end
  else
    io.write(tt .. "\n")
  end
end

--~ local e = function(cmd, raw)
  --~ local f = assert(io.popen(cmd, 'r'))
  --~ local s = assert(f:read('*a'))
  --~ f:close()
  --~ return s
--~ end

local getFile = function(filename)
	local file = assert(io.open(filename))
	local contents = file:read '*a'
	file:close()
	return contents
end

local putFile = function(filename, str, writemode)
	local file = assert(io.open(filename, writemode or "w"))
	file:write(str)
	file:close()
end

--~ local res = e 'find -L src -name "*.c" -or -name "*.lua"'

local docum = {}

local function kw(a)
	return '@'..a..'%s+([^@]+)'
end
string.kwmatch = function(s, a)
	local r = s:match(kw(a))
	if r then
		return string.match(r, '^%s*(.-)%s*$')
	end
end
string.kwgmatch = function(s, a)
	return s:gmatch(kw(a))
end

--~ for i in res:gmatch '[^\n]+' do
	--~ local c = getFile('cheetah.doc')
	--~ local desc, group, gr, sgr, ret, see, fname, fnametrim, farg, text
	--~ for doc, func in c:gmatch '/%*%*(.-) %* %*/%s*([%d%a* _.]+%([%d%a,* _]*%))' do
		--~ doc = doc:gsub('\n %* ', '\n')
		--~ desc = doc:kwmatch('descr')
		--~ assert(desc, 'No @descr secton for function\n\t'..func..'\n')
		--~ group = doc:kwmatch('group')
		--~ assert(group, 'No @group secton for function\n\t'..func..'\n')
		--~ gr, sgr = group:match '([^%s]+)%s*/%s*([^%s]+)'
		--~ if not gr then
			--~ gr, sgr = group, 'nogroup'
		--~ end
		--~ ret = doc:kwmatch('return')
		--~ see = doc:kwmatch('see')
		--~ local vars, varnames = {}, {}
		--~ for k in doc:kwgmatch 'var' do
			--~ table.insert(vars, k:match '^%s*(.-)%s*$')
		--~ end
		--~ fname, farg = func:match '%s*([%d%a* _.]-)%s*%(([%d%a,* _]*)%)'
		--~ fname = fname:gsub('%s*=%s*function%s*$', '')
		--~ fnametrim = fname:match '([%d%a_.]+)%s*$'
		--~ for k in farg:gmatch '[^,]+' do
			--~ table.insert(varnames, k:match'([%d%a_]+)%s*$')
		--~ end
		--~ assert(#varnames == #vars, 'Error in vars count for function\n\t'..func..'\n')
		--~ text = 
		--~ '### cheetah.'..fnametrim ..
		--~ ' <a name="'..fnametrim..'"></a>\n\n' ..
		--~ '`cheetah.'..fnametrim..'('..table.concat(varnames, ', ')..')`\n\n' ..
		--~ desc
		--~ if #varnames > 0 then
			--~ text = text .. '\n\n**Parameters**\n'
			--~ for i = 1, #varnames do
				--~ text = text .. '\n* **'..varnames[i]..'** <br />\n'..vars[i]
			--~ end
		--~ end
		--~ if ret then
			--~ text = text .. '\n\n**Return value**\n\n'..ret
		--~ end
		--~ if see then
			--~ text = text .. '\n\n**See also**\n\n'..see:gsub(' ?([^, ]+)', '* <a href="#wiki-%1">%1</a>\n')
		--~ end
		--~ if not docum[gr] then docum[gr] = {} end
		--~ if not docum[gr][sgr] then docum[gr][sgr] = {} end
		--~ table.insert(docum[gr][sgr], text)
	--~ end
--~ end

--~ local docfiles = {}
--~ 
--~ for k, v in pairs(docum) do
	--~ local text = ''
	--~ for kk, vv in pairs(v) do
		--~ text = text .. '## '..kk:gsub("^%l", string.upper)..
		--~ ' <a name="'..kk:gsub("^%l", string.upper)..'"></a>'..
		--~ '\n\n'..table.concat(vv, '\n\n***\n\n')..'\n\n'
	--~ end
	--~ putFile('../Cheetah.wiki/'..k:gsub("^%l", string.upper)..'.md', text)
--~ end

local description, vars, group, seealso, class, advanced, varreturn, constructor, examples, notes
local lasttable
local function clear_vars()
	description = {}
	vars = {}
	examples = {}
	notes = {}
	varreturn = {}
	group = nil
	seealso = nil
	class = nil
	advanced = false
	constructor = false
	lasttable = nil
end
clear_vars()

local doc_classes = {} --functions by classes
local doc_functions = {} --functions by groups

local function add_func(funcname, func)
	--~ table.print({funcname, description, vars, group, seealso, examples, class, advanced, varreturn, constructor})
	--~ print('--------------------------------')
	if class then
		for cls in class:gmatch('[a-zA-Z]+') do
			--add new class (if not exists)
			if not doc_classes[cls] then doc_classes[cls] = {} end
			table.insert(doc_classes[cls], {funcname = funcname, func = func, description = description, vars = vars, group = group, seealso = seealso, examples = examples, class = cls, advanced = advanced, varreturn = varreturn, constructor = constructor})
		end
	elseif group then
		if not doc_functions[group] then doc_functions[group] = {} end
		table.insert(doc_functions[group], {funcname = funcname, func = func, description = description, vars = vars, group = group, seealso = seealso, examples = examples, class = class, advanced = advanced, varreturn = varreturn, constructor = constructor})
	else
		io.write(io.stderr, 'Function'..funcname..' is without class or group!')
	end
	clear_vars()
end

for line in io.lines('cheetah.doc') do
	local line1 = line:sub(0,1)
	if line:sub(0,2) ~= '--' then
		if line:sub(0,7) == '@descr ' then
			table.insert(description, line:sub(8))
			lasttable = description
		elseif line:sub(0,7) == '@group ' then
			group = line:sub(8)
			lasttable = nil
		elseif line:sub(0,5) == '@see ' then
			seealso = line:sub(6)
			lasttable = nil
		elseif line:sub(0,7) == '@class ' then
			class = line:sub(8)
			lasttable = nil
		elseif line:sub(0,9) == '@advanced' then
			advanced = true
			lasttable = nil
		elseif line:sub(0,12) == '@constructor' then
			constructor = true
			lasttable = nil
		elseif line:sub(0,8) == '@return ' then
			table.insert(varreturn, line:sub(9))
			lasttable = varreturn
		elseif line:sub(0,5) == '@var ' then
			local vartable = {line:sub(6)}
			table.insert(vars, vartable)
			lasttable = vartable
		elseif line:sub(0,6) == '@note ' then
			local notetable = {line:sub(7)}
			table.insert(notes, notetable)
			lasttable = notetable
		elseif line:sub(0,9) == '@example ' then
			local exampletable = {line:sub(10)}
			table.insert(examples, exampletable)
			lasttable = exampletable
		else
			if line1 == '@' then
				lasttable = nil
			else
				funcname = line:match '^[^ ]* ?function ([^(]+)%(.*$'
				if funcname then
					add_func(funcname, line)
				elseif lasttable then
					--append another line for multiline descriptions
					table.insert(lasttable, line)
				end
			end
		end
	end
end
local function subst_class_general(str)
	return str:gsub('%%class%(([^)]+)%)', '<a href="#wiki-%1">%1</a>')
end
local function subst_class(str, class)
	return str:gsub('%%class', '<a href="#wiki-'..class..'">'..class..'</a>')
end

local function process_func(func, class)
	local ret = subst_class_general(func)
	if class then
		ret = subst_class(ret, class)
	end
	return ret
end

local function process_description(descr, class)
	local ret = subst_class_general(descr)
	if class then
		ret = subst_class(ret, class)
	end
	return ret
end

local function format_doc(t)
	local func
	if t.class and not t.constructor then
		func = t.func:gsub('function ', ':')
		print('#### '..t.funcname..' <a name="'..t.class..':'..t.funcname..'"></a>\n')
	else
		local constructor = ''
		if t.constructor then constructor = ' (constructor)' end
		print('#### cheetah.'..t.funcname..constructor..' <a name="'..t.funcname..'"></a>\n')
		func = t.func:gsub('function ', 'cheetah.')
	end
	print('<pre>'..process_func(func, t.class)..'</pre>\n')
	print(process_description(table.concat(t.description, '\n'), t.class))
	if #t.vars > 0 then
		print '\n\n**Parameters**\n'
		for i = 1, #t.vars do
			text = text .. '\n* **'..t.vars[i]..'** <br />\n'..vars[i]
		end
	end
	print()
end

print('## Classes')
for cls, functions in pairs(doc_classes) do
	print('\n### '..cls..'  <a name="'..cls..'"></a>\n')
	for key, value in ipairs(functions) do
		format_doc(value)
	end
end