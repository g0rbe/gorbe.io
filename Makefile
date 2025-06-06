build: clean
	hugo --buildDrafts --minify --printPathWarnings --cleanDestinationDir --destination="public/gorbe.io"
	hugo --buildDrafts --minify --printPathWarnings --cleanDestinationDir --baseURL="http://43cmk4mruizijv76vk5ensj5lq5svgiswaqlyqy4ocq3fugs6zzunpad.onion" --destination="public/43cmk4mruizijv76vk5ensj5lq5svgiswaqlyqy4ocq3fugs6zzunpad.onion"

deploy: build
	rsync --archive --delete --info=progress2 --info=name1 --size-only "public/43cmk4mruizijv76vk5ensj5lq5svgiswaqlyqy4ocq3fugs6zzunpad.onion/" "gorbe.io:/var/www/43cmk4mruizijv76vk5ensj5lq5svgiswaqlyqy4ocq3fugs6zzunpad.onion/"
	rsync --archive --delete --info=progress2 --info=name1 --size-only "public/gorbe.io/" "gorbe.io:/var/www/gorbe.io/"

run:
	hugo server --buildDrafts --enableGitInfo --printPathWarnings --disableFastRender --printMemoryUsage --renderToMemory --forceSyncStatic

clean:
	rm -rf ./public/
	rm -rf ./resources/
	rm -rf ./tmp/

swaggerui: 
	/usr/bin/mkdir tmp
	#/usr/bin/rm -rf static/tools/swagger-ui/
	cd ./tmp && /usr/bin/npm i swagger-ui-dist
	/usr/bin/cp -r ./tmp/node_modules/swagger-ui-dist/* static/tools/swagger-ui/
	# /usr/bin/patch ./static/swagger-ui/index.html swagger-ui.patch

swaggereditor: 
	/usr/bin/mkdir tmp
	#/usr/bin/rm -rf static/tools/swagger-editor/
	cd ./tmp && /usr/bin/npm i swagger-editor-dist
	/usr/bin/cp -r ./tmp/node_modules/swagger-editor-dist/* static/tools/swagger-editor/
	# /usr/bin/patch ./static/swagger-editor/index.html swagger-editor.patch

commitall:
	git add .
	git commit
	git push
	make deploy
