#import "python_style.typ": setup_python
#import "pwndbg_style.typ": setup_pwndbg
#import "my_zsh_style.typ": setup_my_zsh

#let setup_all(body) = {
	body = setup_python(body)
	body = setup_pwndbg(body)
	body = setup_my_zsh(body)
	body
}
