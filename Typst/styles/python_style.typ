#import "colors.typ": Colors

#let setup_python(body) = {
	show raw.where(lang: "python"): txt => block(
		fill: Colors.bg,
		inset: 10pt,
		radius: 2pt,
		width: auto,
		text(fill: Colors.white, txt)
	)
	body
}
