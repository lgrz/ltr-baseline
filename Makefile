
BINDIR=bin
EXTDIR=ext
TARGS=$(addprefix $(BINDIR)/,rbp_eval lightgbm xgboost jforests)

.PHONEY: all clean

all: $(TARGS)

$(TARGS): | $(BINDIR)

$(BINDIR):
	mkdir -p $@

$(BINDIR)/rbp_eval: $(EXTDIR)/rbp_eval-0.2.tar.gz
	tar xf $<
	cd rbp_eval-0.2 && ./configure && make -j8 && cd -
	cp rbp_eval-0.2/rbp_eval/rbp_eval $(BINDIR)
	$(RM) -r rbp_eval-0.2

$(BINDIR)/lightgbm:
	./script/build-lgbm.sh

$(BINDIR)/xgboost:
	./script/build-xgb.sh

$(BINDIR)/jforests:
	./script/build-jf.sh

clean:
	$(RM) -r $(BINDIR)
