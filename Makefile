.PHONY: clean

clean:
	rm Derived_Data/*.csv
	
Derived_Data/Final_Data.csv: \
 Source_Data/Fixture.Data.DEC13.csv #need to fix this so he can specify which one to build. We'll figure it out
	Rscript tidy_data.R ${Game.Week}