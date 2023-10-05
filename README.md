# Worklist and Updates 

## My worklist 
- [ ] occ_issues (under rgbif) is deprecated - any alternatives?
- [ ] (for the future) Code that allows cleaning for multiple species?
- [ ] Explore eddmaps as an extra data source!

Goal: reduce runtime 

| Test (E. con) | Time          | Output|
| ------------- |:-------------:| -----:|
| original code from 2/10| 4:45| 389|
| species_search merge| 2:00| 389|
| change coordinate cleaner to cran| 1:49| 389|
| remove last 2 cc_ functions| 1:25| 389|
| replace cc_ with coordinate_clean| 1:40| 395|
| remove cc_dupl| 1:55| 395|
| original cc_ functions| 1:37| 389|

>> original script test = 2.30 *2020 ;118
>> new script = 1.50 (good!)         ;388
>> original script test = 4.45       ;389

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