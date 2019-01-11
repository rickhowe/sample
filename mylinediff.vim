set diffexpr=MyLineDiff()
function! MyLineDiff()
	for n in ['in', 'new']
		let f_{n} = map(readfile(v:fname_{n}), 'v:key . ":" . v:val')
		call writefile(f_{n}, v:fname_{n})
	endfor
	let opt = '-a --binary '
	if &diffopt =~ 'icase' | let opt .= '-i ' | endif
	if &diffopt =~ 'iwhite' | let opt .= '-b ' | endif
	let f_out = split(system('diff ' . opt . v:fname_in . ' ' . v:fname_new), '\n')
	call writefile(f_out, v:fname_out)
endfunction
" vim: ts=4 sw=4
