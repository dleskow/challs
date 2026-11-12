#import "colors.typ": Colors

#let setup_c(body) = {
	show raw.where(lang: "c"): txt => block(
		fill: Colors.bg,
		inset: 10pt,
		radius: 2pt,
		width: auto,
		text(fill: Colors.white, txt)
	)
	body
}
