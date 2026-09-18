#import "colors.typ": Colors

#let zshColors = (
	normal:        txt => text(fill: rgb("ffffff"), txt),
	white:         txt => text(weight: "bold", fill: rgb("ffffff"), txt),
	green:         txt => text(fill: rgb("5ebdab"), txt),
	blue:          txt => text(fill: rgb("49aee6"), txt),
	user_blue:     txt => text(fill: rgb("367bf0"), txt),
	user_red:      txt => text(weight: "bold", fill: rgb("ec0101"), txt),
	green_comment: txt => text(weight: "bold", fill: rgb("198388"), txt),
)

#let xxdColors = (
	addr:   txt => text(fill: rgb("ffffff"), txt),
	white:  txt => text(weight: "bold", fill: rgb("ffffff"), txt),
	red:    txt => text(weight: "bold", fill: rgb("ec0101"), txt),
	orange: txt => text(weight: "bold", fill: rgb("ff8a18"), txt),
	green:  txt => text(weight: "bold", fill: rgb("47d4b9"), txt),
	blue:   txt => text(weight: "bold", fill: rgb("277fff"), txt),
)

#let xxd_get_color(byte) = {
	if (byte.at(0) == " ") {
		xxdColors.white
		return
	}
	byte = int(byte, base: 16)
	if (byte == 0x0) {
		xxdColors.white
	} else if (byte == 0x9 or byte == 0xa or byte == 0xd) {
		xxdColors.orange
	} else if (byte >= 0x20 and byte < 0x7f) {
		xxdColors.green
	} else if (byte == 0xff) {
		xxdColors.blue
	} else {
		xxdColors.red
	}
}

#let xxd(line) = {
	(xxdColors.addr)(line.slice(0, 10))
	let colors = ()
	let c = 0
	for i in range(10, 10 + 5*8, step: 5) {
		let byte1 = line.slice(i, i+2)
		let byte2 = line.slice(i+2, i+4)
		colors.push(xxd_get_color(byte1))
		colors.push(xxd_get_color(byte2))
		colors.at(c)(byte1)
		c += 1
		colors.at(c)(byte2)
		c += 1
		" "
	}
	c = 0
	for i in range(10 + 5*8 + 1, line.len()) {
		if (c >= 16) {
			break
		}
		colors.at(c)(line.at(i))
		c += 1
	}
	"\n"
}

#let Commands = (
	no:    0,
	xxd:   1,
	other: 2,
)

#let allow_comments(line) = {
	let comment_start = line.matches(regex("\s#|^#")).map(m => m.start)
	let comment = ""
	if comment_start.len() > 0 {
		comment += line.slice(comment_start.at(0))
		line = line.slice(0, comment_start.at(0))
	}
	(zshColors.normal)(line)
	(zshColors.green_comment)(comment)
	"\n"
}

#let parse_command(user, host, path, line) = {
	if line.len() == 0 {
		("\n", Commands.no)
		return
	}
	// For actual commands
	if "┌──(" in line {
		("", Commands.no)
		return
	}
	// If nothing familiar, just print normally
	if not ("C:\\" in line or "└─#" in line) {
		(allow_comments(line), Commands.no)
		return
	}
	if "C:\\" in line {
		line = line.slice(line.position("> ") + 1)
	} else if "└─#" in line {
		line = line.slice(line.position("# ") + 1)
	}
	let comment_start = line.matches(regex("\s#")).map(m => m.start)
	let comment = ""
	if comment_start.len() > 0 {
		comment += line.slice(comment_start.at(0))
		line = line.slice(0, comment_start.at(0))
	}
	let words = line.matches(regex("[^\s]+")).map(m => m.text)
	if words.len() == 0 {
		("\n", Commands.no)
		return
	}
	let txt = (zshColors.user_blue)("┌──(")
	txt += (zshColors.user_red)(user + "㉿" + host)
	txt += (zshColors.user_blue)(")-[")
	txt += (zshColors.white)(path)
	txt += (zshColors.user_blue)("]\n└─")
	txt += (zshColors.user_red)("# ")
	if "sudo" in words.at(0) {
		txt += underline((zshColors.green)(words.at(0))) + " "
		words = words.slice(1)
	}
	let command_str = words.at(0)
	txt += (zshColors.blue)(command_str) + " "
	for w in words.slice(1) {
		if w.at(0) == "-" {
			txt += (zshColors.green)(w)
		} else {
			txt += (zshColors.normal)(w)
		}
		txt += " "
	}
	txt += (zshColors.green_comment)(comment)
	txt += "\n"
	let command = Commands.no

	if "xxd" in command_str {
		command = Commands.xxd
	} else {
		command = Commands.other
	}

	(txt, command)
	return
}

#let my_zsh(user, host, path, output) = {
	let command = Commands.no
	let txt
	let line_count = 0
	for line in output.text.split("\n") {
		if command == Commands.no {
			(txt, command) = parse_command(user, host, path, line)
			txt
		} else if command == Commands.xxd {
			if line.len() == 0 or not line.at(0) == "0" {
				(txt, command) = parse_command(user, host, path, line)
				txt
				continue
			}
			xxd(line)
		} else if command == Commands.other {
			if line.len() == 0 or "C:\\" in line or "└─#" in line {
				(txt, command) = parse_command(user, host, path, line)
				txt
				continue
			}
			allow_comments(line)
		}
	}
}

#let setup_my_zsh(user, host, path, body) = {
	show raw.where(lang: "my_zsh"): txt => block(
		fill: Colors.bg,
		inset: 10pt,
		radius: 2pt,
		width: auto,
		my_zsh(user, host, path, txt)
	)
	body
}
