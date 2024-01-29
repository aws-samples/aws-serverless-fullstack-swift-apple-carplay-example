### Add functions here and link them to builder-bot format MUST BE "build-FunctionResourceName in template.yaml"

build-GetCityFunction: builder-bot
build-GetWeatherFunction: builder-bot
build-GetPlacesFunction: builder-bot
build-CreateMessageFunction: builder-bot

######################  No Change required below this line  ##########################

builder-bot:
	$(eval $@PRODUCT = $(subst build-,,$(MAKECMDGOALS)))
	$(eval $@BUILD_DIR = $(PWD)/.aws-sam/build-swift)
	$(eval $@STAGE = $($@BUILD_DIR)/lambda)
	$(eval $@ARTIFACTS_DIR = $(PWD)/.aws-sam/build/$($@PRODUCT))
	
	# build docker image to compile Swift for Linux
	docker build -f Dockerfile . -t swift-builder

	# prep directories
	mkdir -p $($@BUILD_DIR)/lambda $($@ARTIFACTS_DIR)

	# compile application inside Docker image using source code from local project folder
	docker run --rm -v $($@BUILD_DIR):/build-target -v `pwd`:/build-src -w /build-src swift-builder bash -cl "swift build --static-swift-stdlib --product $($@PRODUCT) -c release --build-path /build-target"

	# create lambda bootstrap file
	docker run --rm -v $($@BUILD_DIR):/build-target -v `pwd`:/build-src -w /build-src swift-builder bash -cl "cd /build-target/lambda && ln -s $($@PRODUCT) /bootstrap"
  
	# copy binary to stage
	cp $($@BUILD_DIR)/release/$($@PRODUCT) $($@STAGE)/bootstrap
  
  	# copy app from stage to artifacts dir
	cp $($@STAGE)/* $($@ARTIFACTS_DIR)