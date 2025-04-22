swift package \
    --allow-writing-to-directory ./docs \
    generate-documentation --target NavigatorUI \
    --disable-indexing \
    --transform-for-static-hosting \
    --output-path ./docs
