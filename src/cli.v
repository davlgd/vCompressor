module main

import os
import runtime { nr_cpus }
import cli { Command, Flag }

pub fn cli_setup( execute fn (cmd Command) ! ) {

	mut app_cli := Command{
		name:          app.name
		version:       app.version
		description:   '${app.description} ${app.url}'
		usage:         app.usage
		required_args: 1
		execute:		execute
		flags:         [
			Flag{
				flag:        .string
				name:        'algorithm'
				abbrev:      'a'
				description: 'Choose the compression algorithm (${compression_algorithms.map(it.name).join(', ')})'
			},
			Flag{
				flag:          .int
				name:          'threads'
				abbrev:        't'
				default_value: [nr_cpus().str()]
				description:   'The number of threads (zstd only, default: ${nr_cpus()})'
			},
			Flag{
				flag:          .int
				name:          'level'
				abbrev:        'l'
				default_value: ['12']
				description:   'The compression level (zstd only, default: 12)'
			},
		]
	}

	app_cli.setup()
	app_cli.parse(os.args)
}
