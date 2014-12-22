# jossemarGT résumé #
The [right word](http://english.stackexchange.com/a/61341) is résumé but it can
be called CV as well. You can read mine [here](RESUME.md) in github (just the
essential) or look [here](http://jossemargt.github.io/resume) for a more elegant
`html` version.

# FAQ #

## Why did you write your resume in markdown?
Because is easy to maintain and publish it as plain text in github :octocat:

## How did you made it?
1. Write resume in markdown notation.
2. `docker run --rm -v $PWD:/data jpbernius/pandoc --standalone --from markdown --to html5 --section-divs --css style/main.css -o index.html RESUME.md`
3. `wkhtmltopdf --page-size Letter index.html download/resume.pdf`
4. `git commit -am "A comment" && git push origin gh-pages`
5. ???
6. Profit

## I want to write one like yours, may I fork this repo?
`TODO` I think that you should [use this repo](#) as boilerplate instead.

## Can I haz docz?
- Pandoc User's Guide -> http://johnmacfarlane.net/pandoc/README.html
- Ch-M.D post -> http://blog.chmd.fr/editing-a-cv-in-markdown-with-pandoc.html
- [tuxtor](https://github.com/tuxtor)'s post (in spanish) -> http://tuxtor.shekalug.org/creando-un-curriculum-con-markdown-pandoc-y-wkhtmltopdf/
