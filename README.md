# USAGE

npm install
npm run puppeteer

# USAGE DOCKER

docker build -t puppeteer-renderer .
docker run --rm --cap-add=SYS_ADMIN -v $(pwd)/output:/app/images puppeteer-renderer
