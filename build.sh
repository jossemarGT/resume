#!/bin/sh
echo  ==============================================================================
echo  :: Generating Resume Page
docker run -v `pwd`:/source --rm jagregory/pandoc --smart --wrap=none --normalize \
        --section-divs --no-highlight \
        --from       markdown_github-hard_line_breaks+yaml_metadata_block \
        --to         html5 \
        --template   docs/resume.template \
        --output     docs/index.html \
        ./RESUME.md  docs/configuration.yaml
