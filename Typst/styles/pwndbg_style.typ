#import "colors.typ": Colors

#let pwndbgColors = (
	normal:          txt => text(fill: rgb("ffffff"), txt),
	pwndbg:          txt => text(weight: "bold", fill: rgb("47d4b9"), txt),
	white:           txt => text(weight: "bold", fill: rgb("ffffff"), txt),
	red:             txt => text(fill: rgb("d41919"), txt),
	red_bold:        txt => text(weight: "bold", fill: rgb("d41919"), txt),
	orange:          txt => text(fill: rgb("fea44c"), txt),
	green:           txt => text(fill: rgb("5ebdab"), txt),
	green_aqua_bold: txt => text(weight: "bold", fill: rgb("47d4b9"), txt),
	green_leaf_bold: txt => text(weight: "bold", fill: rgb("afd700"), txt),
	green_leaf:      txt => text(fill: rgb("afd700"), txt),
	green_comment:   txt => text(weight: "bold", fill: rgb("198388"), txt),
	light_blue:      txt => text(fill: rgb("49aee6"), txt),
	light_blue_2:    txt => text(fill: rgb("5fd7ff"), txt),
	blue:            txt => text(fill: rgb("367bf0"), txt),
	purple:          txt => text(fill: rgb("af87ff"), txt),
)

#let hexdump_get_color(byte) = {
	if (byte.at(0) == " ") {
		pwndbgColors.white
		return
	}
	byte = int(byte, base: 16)
	if (byte == 0x0) {
		pwndbgColors.red
	} else if (byte == 0x7f or byte == 0x80 or byte == 0xff) {
		pwndbgColors.orange
	} else if (byte >= 0x21 and byte < 0x7f) {
		pwndbgColors.white
	} else {
		pwndbgColors.normal
	}
}

#let hexdump(line) = {
	(pwndbgColors.normal)(line.slice(0, 22))
	let colors = ()
	let c = 0
	// First 8
	for i in range(22, 22 + 3*8, step: 3) {
		let byte = line.slice(i, i+2)
		colors.push(hexdump_get_color(byte))
		colors.at(c)(byte)
		c += 1
		" "
	}
	" "
	// Last 8
	for i in range(46+1, 47 + 3*8, step: 3) {
		let byte = line.slice(i, i+2)
		colors.push(hexdump_get_color(byte))
		colors.at(c)(byte)
		c += 1
		" "
	}
	(pwndbgColors.normal)(" |")
	c = 0
	// UTF-8 chars are 3 bytes
	for i in range(71 + 1 + 3, 75 + 8) {
		if (c >= 8) {
			break
		}
		colors.at(c)(line.at(i))
		c += 1
	}
	(pwndbgColors.normal)("|")
	for i in range(83 + 3, 86 + 8) {
		if (c >= 16) {
			break
		}
		colors.at(c)(line.at(i))
		c += 1
	}
	(pwndbgColors.normal)("|")
	"\n"
}

#let print(line) = {
	let sep = line.split(" = ")
	(pwndbgColors.light_blue)(sep.at(0))
	sep = sep.at(1).split("0x")
	(pwndbgColors.normal)(" = " + sep.at(0))
	if not "<" in sep.at(1) {
		(pwndbgColors.blue)("0x" + sep.at(1) + "\n")
		return
	}
	sep = sep.at(1).split(" <")
	(pwndbgColors.blue)("0x" + sep.at(0))
	sep = sep.at(1).split(">")
	(pwndbgColors.normal)(" <")
	(pwndbgColors.orange)(sep.at(0))
	(pwndbgColors.normal)(">\n")
}

#let info_process_mapping(path, line) = {
	if not "0x" in line {
		(pwndbgColors.normal)(line + "\n")
		return
	}
	let sep = line.split("0x")
	(pwndbgColors.blue)("0x" + sep.at(1) + "0x" + sep.at(2))
	(pwndbgColors.normal)("0x" + sep.at(3).slice(0, 8) + "0x" + sep.at(4).slice(0, 8))
	sep = sep.at(4).slice(17)
	(pwndbgColors.normal)(sep.slice(0, 5))
	if "home" in sep.slice(5) {
		sep = sep.slice(5).split("/")
		(pwndbgColors.green)(path + "/" + sep.last())
	} else {
		(pwndbgColors.green)(sep.slice(5))
	}
	"\n"
}

#let checksec(path, line) = {
	let sep = line.split(":")
	(pwndbgColors.normal)(sep.at(0) + ":")
	if "File" in line {
		sep = sep.at(1).split("/")
		(pwndbgColors.normal)(sep.at(0) + path + "/" + sep.last())
	} else if "Arch" in sep.at(1) {
		(pwndbgColors.normal)(sep.at(1))
	} else if "No" in sep.at(1) {
		(pwndbgColors.red)(sep.at(1))
	} else if "Partial" in sep.at(1) {
		(pwndbgColors.orange)(sep.at(1))
	} else {
		(pwndbgColors.green)(sep.at(1))
	}
	"\n"
}

#let breakpoint(line) = {
	let sep = line.split("0x")
	(pwndbgColors.normal)(sep.at(0))
	(pwndbgColors.blue)("0x" + sep.at(1))
	"\n"
}

#let disasm_words = (
	"rbp",
	"ebp",
	"rdi",
	"edi",
	"rsi",
	"esi",
	"rax",
	"eax",
	"rbx",
	"ebx",
	"bl",
	"rcx",
	"ecx",
	"ch",
	"rdx",
	"edx",
	"ptr",
	"byte",
	"qword",
	"dword",
)

#let ctx_disasm(line) = {
	// Linha com instrução
	if line.len() < 10 or "0x" not in line.slice(0, 10) {
		let comments
		if "//" in line {
			comments = "//" + line.split("//").at(1)
			line = line.split("//").at(0)
		}
		(pwndbgColors.normal)(line)
		(pwndbgColors.green_comment)(comments)
		"\n"
		return
	}

	// Possui ênfase ►
	let addr = line.match(regex("0x[^\s]*"))
	if "►" in line {
		(pwndbgColors.normal)("► ")
		(pwndbgColors.green_aqua_bold)(addr.text)
	} else {
		(pwndbgColors.normal)("  " + addr.text)
	}
	line = line.slice(addr.end)

	// Pega instrução
	let op = line.match(regex("\w+"))
	if "j" in op.text or op.text == "call" or op.text == "ret" {
		if "✔" in line {
			(pwndbgColors.green)(" ✔ ")
		} else if "✘" in line {
			(pwndbgColors.red)(" ✘ ")
		} else {
			(pwndbgColors.green_leaf_bold)("   ")
		}
		(pwndbgColors.green_leaf_bold)(op.text)
	} else {
		(pwndbgColors.green_leaf)("   " + op.text)
	}
	(pwndbgColors.normal)((7 - op.text.len()) * " ")
	line = line.slice(op.end)

	if line.len() <= 5 {
		"\n"
		return
	}

	line = line.slice(line.match(regex("[\s]{1,8}")).end)
	let split = line.match(regex("\s{2,}"))
	let asm = line
	let obs = none
	let comments = none
	if split != none {
		asm = line.slice(0, split.start)
		obs = line.slice(split.end - 1)
		if "//" in obs {
			comments = "//" + obs.split("//").at(1)
			obs = obs.split("//").at(0)
		}
	}

	{
		show regex("[0-9][0-9a-fx]*"): txt => (pwndbgColors.purple)(txt)
		show regex("\b(" + disasm_words.join("|") + ")\b"): txt => (pwndbgColors.light_blue_2)(txt)
		(pwndbgColors.normal)(asm)
	}
	{
		show regex("(?i)\b(" + disasm_words.join("|") + ")\b"): txt => (pwndbgColors.red_bold)(txt)
		show regex("<Cannot dereference.*>"): txt => (pwndbgColors.red)(txt)
		(pwndbgColors.normal)(7*" " + obs)
	}
	(pwndbgColors.green_comment)(comments)

	"\n"
}

#let Commands = (
	no:                   0,
	hexdump:              1,
	print:                2,
	info_process_mapping: 3,
	checksec:             4,
	breakpoint:           5,
	ctx_disasm:           6,
	ctx_backtrace:        7,
	other:                8,
)

#let parse_command(line) = {
	if line.len() == 0 {
		("\n", Commands.no)
		return
	}
	// For actual commands
	if "pwndbg" in line {
		line = line.slice(8)
		let words = line.matches(regex("[\w-]+")).map(m => m.text)
		// Empty lines? Idk
		if words.len() == 0 {
			("\n", Commands.no)
			return
		}
		let command_str = words.at(0)
		let command = Commands.no

		if "hexd" in command_str {
			command = Commands.hexdump
		} else if command_str.at(0) == "p" {
			command = Commands.print
		} else if command_str.at(0) == "b" {
			command = Commands.breakpoint
		} else if "info" in command_str {
			// Please do better...
			if "proc" in line and "m" in line {
				command = Commands.info_process_mapping
			}
		} else if "checks" in command_str {
			command = Commands.checksec
		}

		let txt = (pwndbgColors.pwndbg)("pwndbg> ")
		txt += (pwndbgColors.normal)(line)
		txt += "\n"
		(txt, command)
		return
	} else if "DISASM" in line {
		((pwndbgColors.blue)(line) + "\n", Commands.ctx_disasm)
		return
	} else if "BACKTRACE" in line {
		((pwndbgColors.blue)(line) + "\n", Commands.ctx_backtrace)
		return
	}
	((pwndbgColors.normal)(line) + "\n", Commands.other)
}

#let pwndbg(path, output) = {
	let command = Commands.no
	let txt
	let line_count = 0
	for line in output.text.split("\n") {
		if command == Commands.no {
			(txt, command) = parse_command(line)
			txt
		} else if command == Commands.hexdump {
			if line.len() == 0 or not line.at(0) == "+" {
				(txt, command) = parse_command(line)
				txt
				continue
			}
			hexdump(line)
		} else if command == Commands.print {
			if line.len() == 0 or not line.at(0) == "$" {
				(txt, command) = parse_command(line)
				txt
				continue
			}
			print(line)
		} else if command == Commands.info_process_mapping {
			// Use it if literal Ctrl+C, Ctrl+V, when it appears process number and etc
			if line_count >= 1 and line.len() > 0 and not line.at(0) == "0" {
				line_count = 0
				(txt, command) = parse_command(line)
				txt
				continue
			}
			line_count += 1
			info_process_mapping(path, line)
		} else if command == Commands.checksec {
			if line_count > 6 or (line_count > 5 and not line.at(0) == "S") {
				line_count = 0
				(txt, command) = parse_command(line)
				txt
				continue
			}
			line_count += 1
			checksec(path, line)
		} else if command == Commands.breakpoint {
			if line_count >= 1 {
				line_count = 0
				(txt, command) = parse_command(line)
				txt
				continue
			}
			line_count += 1
			breakpoint(line)
		} else if command == Commands.ctx_disasm {
			if "pwndbg" in line  or "-----" in line {
				(txt, command) = parse_command(line)
				txt
				continue
			}
			ctx_disasm(line)
		} else if command == Commands.ctx_backtrace {
			if "pwndbg" in line  or "-----" in line {
				(txt, command) = parse_command(line)
				txt
				continue
			}
			(pwndbgColors.normal)(line + "\n")
		} else if command == Commands.other {
			if "pwndbg" in line  or "-----" in line {
				line_count = 0
				(txt, command) = parse_command(line)
				txt
				continue
			}
			line_count += 1
			(pwndbgColors.normal)(line + "\n")
		}
	}
}

#let setup_pwndbg(path, body) = {
	show raw.where(lang: "pwndbg"): txt => block(
		fill: Colors.bg,
		inset: 10pt,
		radius: 2pt,
		pwndbg(path, txt)
	)
	body
}
