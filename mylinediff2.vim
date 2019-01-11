set diffexpr=MyLineDiff2()
function! MyLineDiff2()
	let f_in = readfile(v:fname_in) + ['']
	let f_new = readfile(v:fname_new) + ['']
	let l = min([len(f_in), len(f_new)])
	let f_in[l - 1] = ''
	let f_new[l - 1] = ''
	if &diffopt =~ 'icase'
		call map(f_in, 'tolower(v:val)')
		call map(f_new, 'tolower(v:val)')
	endif
	if &diffopt =~ 'iwhiteall'
		call map(f_in, 'substitute(v:val, "\\s\\+", "", "g")')
		call map(f_new, 'substitute(v:val, "\\s\\+", "", "g")')
	elseif &diffopt =~ 'iwhite'
		call map(f_in, 'substitute(v:val, "\\s\\+", " ", "g")')
		call map(f_in, 'substitute(v:val, "\\s\\+$", "", "")')
		call map(f_new, 'substitute(v:val, "\\s\\+", " ", "g")')
		call map(f_new, 'substitute(v:val, "\\s\\+$", "", "")')
	elseif &diffopt =~ 'iwhiteeol'
		call map(f_in, 'substitute(v:val, "\\s\\+$", "", "")')
		call map(f_new, 'substitute(v:val, "\\s\\+$", "", "")')
	endif
	let f_out = []
	let [x, y] = [0, 0]
	for n in range(l)
		if f_in[n] !=# f_new[n]
			if x == 0
				let x = n + 1
			else
				let y = n + 1
			endif
		else
			if y != 0
				let f_out += [x . ',' . y . 'c' . x . ',' . y]
			elseif x != 0
				let f_out += [x . 'c' . x]
			endif
			let [x, y] = [0, 0]
		endif
	endfor
	call writefile(f_out, v:fname_out)
endfunction
" vim: ts=4 sw=4
