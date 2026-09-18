#import "python_style.typ": setup_python
#import "pwndbg_style.typ": setup_pwndbg
#import "my_zsh_style.typ": setup_my_zsh
#import "ida_style.typ": setup_ida

#let setup_all(user, host, path, local_vars: (), global_vars: (), raw_size: 7pt, body) = {
	// Raw blocks
	body = setup_python(body)
	body = setup_pwndbg(path, body)
	body = setup_my_zsh(user, host, path, body)
	body = setup_ida(local_vars: local_vars, global_vars: global_vars, body)
	show raw.where(block:true): set text(size: raw_size)
	show raw.where(block:true): set block(width: 100%)
	// Title
	show title: set align(center)
	show title: set text(size: 22pt)
	// Paragraphs
	set par(justify: true)
	// Page (Header / Footer)
	set page(header: context {
			let prev_ones = query(selector(heading).before(here()))
			let next_ones = query(selector(heading).after(here()))
			let next_here = next_ones.filter(h => h.location().page() == here().page())
			let heading = none
			let chall = emph("chall: ") + document.title
			if next_here.len() > 0 {
				heading = next_here.first().body
			} else if prev_ones.len() > 0 {
				heading = prev_ones.last().body
			}
			if here().page() == 1 {
				chall = none
				heading = "Write-up: " + document.title
			}
			grid(
				columns: (1fr, auto, 1fr),
				image("ganesh.svg", height: 3em),
				align(center + horizon, chall),
				align(right + horizon, heading)
			)
		},
		footer: align(right+horizon, context counter(page).display()))
	// Sections
	show heading.where(level: 1): set text(size: 16pt)
	show heading.where(level: 2): set text(size: 14pt)
	show heading.where(level: 3): set text(size: 12pt)
	show heading.where(level: 3): set heading(numbering: none)
	show heading.where(level: 4): set text(size: 11pt, style: "italic")
	show heading.where(level: 4): set heading(numbering: none)
	// Show only numbers in references
	show ref: it => {
		let el = it.element
		if el == none { return it }
		link(
			el.location(), 
			// Links and numbers, remove the dot at the end
			numbering(el.numbering, ..counter(el.func()).at(el.location())).slice(0, -1)
		)
	}
	body
}
