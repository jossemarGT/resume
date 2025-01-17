package main

import (
	"dagger.io/dagger"
	"universe.dagger.io/docker"
)

dagger.#Plan & {
	client: {
		filesystem: {
			"./": read: {
				contents:	dagger.#FS
				exclude: [
					".github",
					"cue.mod",
					"dist",
					".git",
					"*.cue",
					"*.pdf",
				]
			}
			"./dist/site": write: contents: actions.site.generatePage.export.directories."docs"
			"./dist/pdf": write: contents: actions.pdf.printPDF.export.directories."dist"
		}
	}
	actions: {
		site: {
			// Pull build context
			pandoc: docker.#Pull & {
				source: "portown/alpine-pandoc"
			}

			// Prepare environment
			_addSource: docker.#Copy & {
				input:    pandoc.output
				contents: client.filesystem."./".read.contents
				dest: "/data"
			}

			// Generate page
			generatePage: docker.#Run & {
				input: _addSource.output
				workdir: "/data"
				command: {
					name: "pandoc"
					args: ["./RESUME.md", "docs/configuration.yaml"]
					flags: {
						"--verbose": true,
						"--fail-if-warnings": true,
						"--standalone": true,
						"--section-divs": true,
						"--no-highlight": true,
						"--wrap": "none",
						"--columns": "1000",
						"--from": "markdown_github+yaml_metadata_block+auto_identifiers+smart-hard_line_breaks+pipe_tables",
						"--to": "html5",
						"--template": "docs/resume.template",
						"--output": "docs/index.html"
					}
				}
				export: {
					directories: "docs": _
				}
			}

		}
		pdf: {
			// Pull build context
			printer: docker.#Pull & {
				source: "madnight/docker-alpine-wkhtmltopdf"
			}

			// Prepare environment
			_addPage: docker.#Copy & {
				input:    printer.output
				contents: site.generatePage.export.directories."docs"
				dest: "/data"
			}

			_prepare: docker.#Run & {
				input: _addPage.output
				workdir: "/data"
				entrypoint: []
				command: {
					name: "ash"
					args: ["-c", "mkdir -p dist"]
				}
			}

			// Print PDF
			printPDF: docker.#Run & {
				input: _prepare.output
				entrypoint: []
				workdir: "/data"
				command: {
					name: "wkhtmltopdf"
					args: ["index.html", "dist/jossemargt-resume.pdf"]
					flags: {
						"--no-background": true,
						"--print-media-type": true,
						"--enable-local-file-access": true,
						"--disable-javascript": true,
						"--page-size": "Letter",
						"-T": "15",
						"-R": "13",
						"-B": "13",
						"-L": "13",
						"--user-style-sheet": "stylesheets/wkhtmltopdf.css"
					}
				}
				export: {
					directories: "dist": _
				}
			}
		}
	}
}
