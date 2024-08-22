build:
	hugo --enableGitInfo --buildDrafts --minify

run:
	hugo server --buildDrafts --enableGitInfo

clean:
	rm -rf ./public/
	rm -rf ./resources/
	rm -rf ./tmp/
	rm -rf ./node_modules/
	rm -f package.json
	rm -f package-lock.json
	rm -f tailwind.config.js

swaggerui: clean
	/usr/bin/mkdir tmp
	#/usr/bin/rm -rf static/tools/swagger-ui/
	cd ./tmp && /usr/bin/npm i swagger-ui-dist
	/usr/bin/cp -r ./tmp/node_modules/swagger-ui-dist/* static/tools/swagger-ui/
	# /usr/bin/patch ./static/swagger-ui/index.html swagger-ui.patch

swaggereditor: clean
	/usr/bin/mkdir tmp
	#/usr/bin/rm -rf static/tools/swagger-editor/
	cd ./tmp && /usr/bin/npm i swagger-editor-dist
	/usr/bin/cp -r ./tmp/node_modules/swagger-editor-dist/* static/tools/swagger-editor/
	# /usr/bin/patch ./static/swagger-editor/index.html swagger-editor.patch