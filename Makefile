build:
	hugo --enableGitInfo --buildDrafts --minify

run:
	hugo server --buildDrafts --enableGitInfo

clean:
	rm -rf ./public/
	rm -rf ./node_modules/
	rm -f package.json
	rm -f package-lock.json
	rm -f tailwind.config.js
