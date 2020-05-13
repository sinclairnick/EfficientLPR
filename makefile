environment:
	sudo pip3 install gdown
	sudo apt-get install libsm6 libxrender1 libfontconfig1
	pip3 install -r requirements.txt
	python3 setup.py build_ext --inplace

raw-data:
	$(shell gdown --id 1Txdl3Rjsva3ggGNZOF4y78iyTysnffh4 -O data/raw/nzvd.tar.gz) 
	$(shell gdown --id 1S6MWdY9_fk83rCHjkb6e4AJ5183pDM8W -O data/raw/stanford-cars.tar.gz)
	$(shell tar -C data/raw -zxvf data/raw/nzvd.tar.gz)
	$(shell tar -C data/raw -zxvf data/raw/stanford-cars.tar.gz) 

processed-data:
	python3 data/src/make-data.py

PHI=0
LR=0.001
STEPS=10
EPOCHS=200
HINGE=--hinge_loss
WANDB=--wandb
DROPOUT_RATE=0.5

PRETRAIN_DIR=data/processed/stanford-cars
TRAIN_DIR=data/processed/nzvd

pretrain:
	python3 train.py \
    --gpu 0 \
    --freeze-backbone \
    --weighted-bifpn \
    --compute-val-loss \
    --random-transform \
    --batch-size 32 \
    --snapshot imagnet \
    --phi ${PHI} \
    --lr ${LR} \
    --steps ${STEPS} \
    --epochs ${EPOCHS} \
    --dropout_rate ${DROPOUT_RATE} \
	${HINGE} ${WANDB} \
    csv ${PRETRAIN_DIR}/train-annotations.csv data/processed/classes.csv data/colors.csv \
    --val-annotations data/val-annotations.csv

train:
	python3 train.py \
	--gpu 0 \
	--freeze-backbone \
	--weighted-bifpn \
	--compute-val-loss \
	--random-transform \
	--batch-size 32 \
	--snapshot imagnet \
	--phi ${PHI} \
	--lr ${LR} \
	--steps ${STEPS} \
	--epochs ${EPOCHS} \
	--dropout_rate ${DROPOUT_RATE} \
	${FLAGS} \
	csv ${TRAIN_DIR}train-annotations.csv \
	data/classes.csv data/colors.csv \
	--val-annotations ${TRAIN_DIR}val-annotations.csv