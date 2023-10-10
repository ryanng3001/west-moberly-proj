# Worklist and Updates 

## My worklist 
- [ ] occ_issues (under rgbif) is deprecated - any alternatives?
- [ ] (for the future) Code that allows cleaning for multiple species?
- [ ] Explore eddmaps as an extra data source!

## Current progress (as of 9/10)
- Managed to work through 14 species 
- For some reason for large datasets, cc_outl is not working... 
Testing geographic outliers
Error in h(simpleError(msg, call)) : 
  error in evaluating the argument 'x' in selecting a method for function 'ext': [vect] the variable name(s) in argument `geom` are not in `x`
In addition: Warning message:
In cc_outl(species_data) : Using raster approximation.
- Think issue relates to size of df; 9999 ok but 10000 fail 
- https://github.com/ropensci/CoordinateCleaner/issues/21 
- Will just remove cc_outl if >10000


## Curernt progress (as of 8/10)
- cc_inst is slow because it filters species obs based on a record of 10,000+ biological instutitions 
- # filtered is actually quite insignificant 
- propose to remove this line for large datasets (>10000)

## Current progress (as of 4/10)
- Finalized cleaning script - now work on extracting data and creating plots 
- Should redo the original 5 species... since we are now using a new script 
- Goal: reduce runtime!!! 

| Test (E. con) | Time          | Output|
| ------------- |:-------------:| -----:|
| original code from 2/10| 4:45| 389|
| species_search merge| 2:00| 389|
| change coordinate cleaner to cran| 1:49| 389|
| remove last 2 cc_ functions| 1:25| 389|
| replace cc_ with coordinate_clean| 1:40| 395|
| remove cc_dupl| 1:55| 395|
| original cc_ functions| 1:37| 389|

Result: Commit to the species_search merge; everything else the same. Coordinate_clean seems to be slower; cannot remove cc_dupl because some records were removed by it. Overall reduced run time by half! 

## Current progress (as of 2/10)
- Obtained maps and histograms for 5 plant species in brainstorming doc 
- Addressed the issue of CoordinateCleaner being retired !!! (downloaded another version from GitHub; 3.0)
- Note that the new version of CoordinateCleaner no longer require renaming column to decimallongitude and decimallatitude (will give error otherwise!!!)
- Only issue now is occ_issues deprecation... but not an urgent concern 

## Current progress (as of 26/9) 
- Deciphered Hazel's script (adapted from Emma's paper)
- Found some packages that were installed but not used (I think) so I removed them
- Fixed minor stuff in the code caused by R updates 
- Replicated map and histogram for Eurybia conspicua (low occurrence) 