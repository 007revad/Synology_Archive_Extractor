# Synology_Archive_Extractor

usage:
<p align="leftr"><img src="images/sae.png"></p>

Supports all synoarchive types.

Run it on your own nas, with root privilege.

On x86 linux, the required libraries are located in /usr/lib:

  libcrypto.so.1.1   
  libicudata.so.64  
  libicui18n.so.64    
  libicuuc.so.64   
  libmsgpackc.so.2  
  libsodium.so  
  libsynocodesign.so   
  libsynocore.so.7   
  libsynocredentials.so.7   
  libsynocrypto.so.7 

<br>

## Using the syno_archive_extractor.sh to simplify things

Edit the 3 variables near the top of the script to suit your folder locations:

```bash
# Location of the folder containing the files to extract
inpath="/volume1/temp/in"

# Location of the folder extract to
outpath="/volume1/temp/out"

# Location of the sae.py script
pyscript="/volume1/scripts/sae/sae.py"
```

Then place the files to be extracted in he in folder
<p align="leftr"><img src="images/image1.png"></p>

Run the syno_archive_extractor.sh bash script
<p align="leftr"><img src="images/image2.png"></p>

The extracted files will be in their own folder in the out folder
<p align="leftr"><img src="images/image3.png"></p>

Extracted BeeStation pat file
<p align="leftr"><img src="images/image4.png"></p>

Extracted DSM small update pat file
<p align="leftr"><img src="images/image5.png"></p>

Extracted Synology drive database update
<p align="leftr"><img src="images/image6.png"></p>

Extracted Synplogy package
<p align="leftr"><img src="images/image7.png"></p>

<br>
