/**
 * Resume functions
 */
import { dag, Directory, File, object, func } from "@dagger.io/dagger";

@object()
export class Resume {
  /**
   * Generates new configuration yaml file with today's date
   *
   * @param target File path where the date will be updated
   * @returns File with the most recent date (use export to replace existing one)
   */
  @func()
  bumpDate(target: File): File {
    const today = new Date().toLocaleDateString("en-US", {
      year: "numeric",
      month: "long",
      day: "numeric",
    });

    return dag
      .container()
      .from("alpine")
      .withWorkdir("/tmp")
      .withFile(`/tmp/${target.name}`, target)
      .withExec([
        "sed",
        "-i",
        `s/date:.*/date:   ${today}/`,
        `/tmp/${target.name}`,
      ])
      .file(`/tmp/${target.name}`);
  }

  /**
   * Renders this resume web representation.
   *
   * NOTE: This build logic goes under the assumption that all the site related
   * assets are in the `/docs` directory within the src param, as well the
   * source markdown file name.
   *
   * @param src Directory with the source markdown
   * @returns Directory with the website page alongside its static assets
   */
  @func()
  buildSite(src: Directory): Directory {
    return dag
      .container()
      .from("portown/alpine-pandoc")
      .withDirectory("/data", src)
      .withWorkdir("/data")
      .withExec([
        "pandoc",
        "--verbose",
        "--fail-if-warnings",
        "--standalone",
        "--section-divs",
        "--no-highlight",
        "--wrap=none",
        "--columns=1000",
        "--from=markdown_github+yaml_metadata_block+auto_identifiers+smart-hard_line_breaks+pipe_tables",
        "--to=html5",
        "--template=docs/resume.template",
        "--output=docs/index.html",
        "./RESUME.md",
        "docs/configuration.yaml",
      ])
      .directory("/data/docs");
  }

  /**
   * Renders this resume PDF representation.
   *
   * NOTE: It still has hardcoded the path to the main input file, output name
   * and style override relative path.
   *
   * @param src Dierctory path with the web version of the resume
   * @returns File PDF artifact (use `export` to dump into a directory)
   */
  @func()
  buildPdf(src: Directory): File {
    return dag
      .container()
      .from("madnight/docker-alpine-wkhtmltopdf")
      .withDirectory("/data", src)
      .withWorkdir("/data")
      .withExec([
        "wkhtmltopdf",
        "--no-background",
        "--no-outline",
        "--print-media-type",
        "--enable-local-file-access",
        "--debug-javascript",
        "--page-size",
        "Letter",
        "-T", "12",
        "-R", "12",
        "-B", "12",
        "-L", "12",
        "--user-style-sheet",
        "stylesheets/wkhtmltopdf.css",
        "index.html",
        "jossemargt-resume.pdf",
      ])
      .file("jossemargt-resume.pdf");
  }

  /**
   * Builds all the artifacts for this project.
   *
   * @param src assets root path
   * @returns Directory with all the artifacts (use `export` to get the files)
   */
  @func()
  build(src: Directory): Directory {
    const siteDirectory = this.buildSite(src);
    const pdfFile = this.buildPdf(siteDirectory);

    return dag
      .directory()
      .withDirectory("site", siteDirectory)
      .withFile("pdf/jossemargt-resume.pdf", pdfFile);
  }
}
