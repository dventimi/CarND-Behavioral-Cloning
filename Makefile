#!/usr/bin/Make -f

export SHELL=/bin/bash
export TRAINING_INDEX=data/driving_log_train.csv
export VALIDATION_INDEX=data/driving_log_validation.csv
export BASE_PATH=data/
export SAMPLES_PER_EPOCH=7000
export VALID_SAMPLES_PER_EPOCH=7000
export EPOCHS=5
export BATCH_SIZE=100
export FLIP=no
export SHIFT=no

.ONESHELL:

.PHONY: environment docs validate simulator telemetry clean cleandocs cleandata cleanmodel cleansimulators

# Phony targets

environment: 
	conda env create --file environment.yml --name CarND-Behavioral-Cloning

docs: Makefile.svg

validate: telemetry simulator

simulator: simulator-linux simulator-beta
	"simulator-linux/Default Linux desktop Universal.x86_64"

telemetry: model.h5
	source activate CarND-Behavioral-Cloning
	python drive.py model.json

clean: cleandocs cleandata cleanmodel cleansimulators

cleandocs:
	rm -f end-to-end-dl-using-px.pdf
	rm -f Makefile.svg

cleandata:
	rm -rf data
	rm -f data.zip

cleanmodel:
	rm -f model.json
	rm -f model.h5

cleansimulators:
	rm -rf simulator-linux
	rm -rf simulator-beta
	rm -rf simulator-linux.zip
	rm -rf simulator-beta.zip

# File targets

model.h5: model.json

model.json: data/driving_log_train.csv data/driving_log_validation.csv
	source activate CarND-Behavioral-Cloning
	python model.py

data/driving_log.csv: data.zip
	unzip -u $< > /dev/null 2>&1
	rm -rf __MACOSX

data.zip:
	wget -nc "https://d17h27t6h515a5.cloudfront.net/topher/2016/December/584f6edd_data/data.zip"

data/driving_log_all.csv: data/driving_log.csv
	cat $< | tail -n+2 | shuf > $@

data/driving_log_train.csv: data/driving_log_all.csv
	cat $< | head -n7000 > $@

data/driving_log_validation.csv: data/driving_log_all.csv
	cat $< | tail -n+7000 > $@

data/driving_log_overtrain.csv: data/driving_log_all.csv
	cat <(cat $< | sort -k4 -n -t, | head -n1) <(cat $< | sort -k4 -nr -t, | head -n1) <(cat $< | awk -F, -vOFS=, '{print $$1, $$2, $$3, sqrt($$4*$$4), $$5, $$6, $$7}' | sort -k4 -n -t, | head -n1) > $@

end-to-end-dl-using-px.pdf:
	wget "https://images.nvidia.com/content/tegra/automotive/images/2016/solutions/pdf/end-to-end-dl-using-px.pdf"

drive.py:
	wget -O - "https://d17h27t6h515a5.cloudfront.net/topher/2017/January/586c4a66_drive/drive.py" | dos2unix > $@

Makefile.svg:
	cat Makefile | python makefile2dot.py | dot -Tsvg > $@

simulator-linux.zip:
	wget -O $@ "https://d17h27t6h515a5.cloudfront.net/topher/2016/November/5831f0f7_simulator-linux/simulator-linux.zip"

simulator-beta.zip:
	wget -O $@ "https://d17h27t6h515a5.cloudfront.net/topher/2017/January/587527cb_udacity-sdc-udacity-self-driving-car-simulator-dominique-development-linux-desktop-64-bit-5/udacity-sdc-udacity-self-driving-car-simulator-dominique-development-linux-desktop-64-bit-5.zip"

simulator-linux: simulator-linux.zip
	unzip -d $@ -u $< > /dev/null 2>&1

simulator-beta: simulator-beta.zip
	unzip -d $@ -u $< > /dev/null 2>&1
