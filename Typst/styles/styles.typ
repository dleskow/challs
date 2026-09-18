#import "python_style.typ": setup_python
#import "pwndbg_style.typ": setup_pwndbg
#import "my_zsh_style.typ": setup_my_zsh
#import "ida_style.typ": setup_ida

#let setup_all(user, host, path, local_vars: (), global_vars: (), body) = {
	body = setup_python(body)
	body = setup_pwndbg(path, body)
	body = setup_my_zsh(user, host, path, body)
	body = setup_ida(local_vars: local_vars, global_vars: global_vars, body)
	// Title
	show title: set align(center)
	show title: set text(size: 22pt)
	// Paragraphs
	set par(justify: true)
	// Show only numbers in references
	show ref: it => {
	  let el = it.element
	  if el == none { return it }
	  link(
	    el.location(), 
	    numbering(el.numbering, ..counter(el.func()).at(el.location()))
	  )
	}
	body
}
