function! s:dcharTOhtml(sl, el) abort
	if !exists('t:DChar')
		call tohtml#Convert2HTML(a:sl, a:el)
		return
	endif
	" 1. disable current syntax (because impossible to mix with DChar ones)
	silent syntax off
	let gs = {}
	" 2. find DChar pos in getmatches() and set syntax with it
	for k in [1, 2]
		let id = [] | for md in values(t:DChar.mid[k]) | let id += md | endfor
		for gm in filter(getmatches(t:DChar.wid[k]),
												\'index(id, v:val.id) != -1')
			let gp = gm.group
			if !empty(filter(gm, 'v:key =~ "pos\\d\\+" && len(v:val) == 3'))
				let gs[gp] = 0
				call win_execute(t:DChar.wid[k],
							\map(values(gm), '"silent syntax match " . gp .
						\" /\\%" . v:val[0] . "l\\%" . v:val[1] . "c.\\+\\%" .
											\(v:val[1] + v:val[2]) . "c/"'))
			endif
		endfor
	endfor
	" 3. call TOhtmml
	call tohtml#Convert2HTML(a:sl, a:el)
	" 4. modify html tags: (1) DT -> DC (2) DCharHL + DC -> DCharHL
	if !empty(gs)
		let [dc, dt] = ['DiffChange', 'DiffText']
		let lc = [line('.'), col('.')]
		call execute('silent %s/<span class="[^"]\{-}\zs\<' . dt .
											\'\>\ze[^"]\{-}">/' . dc . '/ge')
		call execute('silent %s/<span class="[^"]\{-}\<\(' .
								\join(keys(gs), '\|') . '\)\>\zs \+\<' . dc .
													\'\>\ze[^"]\{-}">//ge')
		call cursor(lc)
	endif
	" 5. resume the original syntax
	silent syntax on
endfunction

command! -range=% -bar TOhtml call s:dcharTOhtml(<line1>, <line2>)
"command! -range=% -bar TOhtmlDC call s:dcharTOhtml(<line1>, <line2>)

" vim: ts=4 sw=4
