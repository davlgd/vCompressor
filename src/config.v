module main

struct App {
	name        string
	version     string
	description string
	url         string
	usage       string
}

struct CompressionAlgorithm {
	choice    int
	name      string
	extension string
}

const app := App{
	name:        "vCompressor"
	version:     "0.1.0"
	description: "A simple CLI tool in V for compressing files (https://github.com/davlgd/vCompressor)"
	url:         "https://github.com/davlgd/vCompressor"
	usage:       'path/to/file.ext'
}

const compression_algorithms = [
	CompressionAlgorithm{
		choice:    1
		name:      'deflate'
		extension: 'zip'
	},
	CompressionAlgorithm{
		choice:    2
		name:      'gzip'
		extension: 'gz'
	},
	CompressionAlgorithm{
		choice:    3
		name:      'zlib'
		extension: 'zlib'
	},
	CompressionAlgorithm{
		choice:    4
		name:      'zstd'
		extension: 'zst'
	},
]
