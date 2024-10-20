module main

import compress.deflate
import compress.gzip
import compress.zlib
import compress.zstd

import cli { Command }
import os { create, exists, is_dir, read_bytes }
import readline { read_line }
import runtime { nr_cpus }
import term { red, yellow }
import time

fn compressor(cmd Command) ! {
	if cmd.args.contains('-a') || cmd.args.contains('-t') || cmd.args.contains('-l') {
		eprintln(red('[Error] The file path must be the last argument'))
		println(cmd.help_message())
		exit(1)
	}

	mut file_to_compress := ''

	if cmd.args.len > 0 {
		file_to_compress = cmd.args[0]
	} else {
		file_to_compress = read_line('Enter the file to compress path: ')!
	}

	if !exists(file_to_compress) {
		eprintln("The file '${file_to_compress}' does not exist")
		exit(1)
	}

	if is_dir(file_to_compress) {
		eprintln("The file '${file_to_compress}' is a directory")
		exit(1)
	}

	mut content := read_bytes('${file_to_compress}') or {
		eprintln("Error while reading the file '${file_to_compress}'")
		exit(1)
	}

	mut algorithm := cmd.flags.get_string('algorithm') or { '' }
	mut level := cmd.flags.get_int('level')!
	mut threads := cmd.flags.get_int('threads')!

	if algorithm == 'zstd' && (threads < 1 || threads > nr_cpus()) {
		println(yellow('[WARN] Number of threads to use is incorrect, using the default value: ${nr_cpus()}'))
		threads = nr_cpus()
	}

	if algorithm == 'zstd' && (level < 1 || level > 22) {
		println(yellow('[WARN] Compression level is incorrect, using the default value: 16'))
		level = 16
	}

	zstd_parameters := cmd.flags.get_all_found().filter(it.name == 'level' || it.name =='threads')
	if zstd_parameters.len > 0 && algorithm != 'zstd' {
		println(yellow('[WARN] Compression level and threads to use are only available with the zstd algorithm, these parameters will be ignored'))
	}

	mut choice := ''

	if algorithm == '' {
		println('Choose the compression algorithm:')
		for algo in compression_algorithms {
			println('${algo.choice}. ${algo.name}')
		}

		choice = read_line('> ')!
	} else {
		choice = compression_algorithms.filter(it.name == algorithm)[0].choice.str()
	}

	start_time := time.now()

	match choice {
		'1', '2', '3' {
			extension := compression_algorithms.filter(it.choice == choice.int())[0].extension
			println("🚀 Compressing '${file_to_compress}' with the '.${extension}' extension...")
			mut compressed_file := create('${file_to_compress}.${extension}')!
			compressed := match choice {
				'1' { deflate.compress(content)! }
				'2' { gzip.compress(content)! }
				'3' { zlib.compress(content)! }
				else { ''.bytes() }
			}
			compressed_file.write(compressed)!
			compressed_file.close()
		}
		'4' {
			println("🚀 Compressing '${file_to_compress}' with the '.zstd' extension (level: ${level}, threads: ${threads.str()})...")
			mut compressed_file := create('${file_to_compress}.zstd')!
			compressed := zstd.compress(content, nb_threads: threads, compression_level: level)!
			compressed_file.write(compressed)!
			compressed_file.close()
		}
		else {
			eprintln('Invalid compression algorithm')
			exit(1)
		}
	}

	end_time := time.now()
	elapsed_time := end_time - start_time
	println('✅ Done in ${elapsed_time.str()}')
}
