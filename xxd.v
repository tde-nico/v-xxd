module main

import os

const line_len := 16
const chunk_len := 2

fn dump_hex(mut buf []u8) {
	mut offset := 0
	for _ in 0..((buf.len-1)/16)+1 {
		print("${offset:08x}: ")
		for chunk in 0..line_len/chunk_len {
			for off in 0..chunk_len {
				if offset + chunk*2 + off < buf.len {
					print("${buf[offset + chunk*2 + off]:02x}")	
				} else {
					print("  ")
				}
			}
			print(" ")
		}
		print(" ")
		for curr in offset..offset+line_len {
			if curr >= buf.len {
				break
			}
			chr := buf[curr]
			if chr >= 0x20 && chr <= 0x7e {
				print("${chr.ascii_str()}")
			} else {
				print(".")
			}
		}
		offset += line_len
		print("\n")
	}
}

fn main() {
	if os.args.len < 2 {
		mut lines := os.get_raw_lines_joined()
		lines.split("")
		mut bytes := lines.bytes()
		dump_hex(mut bytes)
		return
	}

	filepath := os.args[1]
	mut file := os.open(filepath) or {
		if err.code() == 2 {
			println("File '${filepath}' does not exist")
			return
		}
		println("${err}")
		return
	}
	defer { file.close() }

	stat := os.stat(filepath) or { return }
	mut buf := []u8{len: int(stat.size)}
	r := file.read(mut &buf) or { return }
	if u64(r) != stat.size {
		return
	}

	dump_hex(mut buf)
}
