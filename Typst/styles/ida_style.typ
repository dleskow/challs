#let idaColors = (
	bg:     rgb("2d2d2d"),
	text:   rgb("ababab"),
	cyan:   rgb("00ffff"),
	yellow: rgb("ffd200"),
	bege:   rgb("ffecbb"),
)


#let setup_ida(local_vars: (), global_vars: (), body) = {
	show raw.where(lang: "ida"): txt => {
	let new_text = txt.text.replace(regex("// ([^\[](.*\n\s*\/\/)*.*)"), m => "/* " + m.captures.at(0).replace("//", " *") + "\n" + 24*"\t" + " */")
		block(
			fill: idaColors.bg,
			inset: 10pt,
			radius: 2pt,
			width: auto,
			text(fill: idaColors.text, {
				show regex("\b(" + local_vars.join("|") + ")\b"): set text(fill: idaColors.cyan)
				show regex("\b(" + global_vars.join("|") + ")\b"): set text(fill: idaColors.bege)
				show regex("\b([va]\d+)\b"): set text(fill: idaColors.cyan)
				show regex("\b([si])\b"): set text(fill: idaColors.cyan)
				show regex("\b(buf)\b"): set text(fill: idaColors.cyan)
				show regex("\b(__(int|fastcall).*)\b"): set text(fill: idaColors.yellow)
				show regex("\b(__.*)\b"): set text(fill: idaColors.bege)
				show regex("\b(_\w.*)\b"): set text(fill: idaColors.bege)
				show regex("\b(std.*)\b"): set text(fill: idaColors.bege)
				show regex("\b(\d*u)\b"): set text(fill: idaColors.text)
				raw(lang: "c", theme: "ida_dark.tmTheme", block: true, new_text)
			})
		)
	}
	body
}
