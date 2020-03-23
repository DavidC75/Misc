macro "import_raw_vol [v]" {
/*
	 Copyright 2017 University of Southampton
	 Charalambos Rossides
	 Bio-Engineering group
	 Faculty of Engineering and the Environment

	 Licensed under the Apache License, Version 2.0 (the "License");
	 you may not use this file except in compliance with the License.
	 You may obtain a copy of the License at

	     http://www.apache.org/licenses/LICENSE-2.0

	 Unless required by applicable law or agreed to in writing, software
	 distributed under the License is distributed on an "AS IS" BASIS,
	 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	 See the License for the specific language governing permissions and
	 limitations under the License.

	------------

	ImageJ/FiJi macro to automate the process of imprting .vol or .raw files.
	Bound to the keyboard shortcut [v], it opens a system dialog where the user selects a .vgi, .vol or .raw file to improt.
	It assumes that a .raw filename is of the format <<path_to_file>>_<<SizeX>>x<<SizeY>>x<<SizeZ>>x<<Bitsize>>bit
	or a .vol file and a .vgi file exist in the same directory, with the .vgi file containing the necessary information to import the .vol file.
	It also assumes that .raw files are saved in big-endian order, whereas .vol files are saved in little-endian order.
	The special characters ".", "[" and "]" are allowed in the path.
*/

	path = File.openDialog("Import .vgi/.vol or .raw file:");
	pathfile = substring(path, 0, lastIndexOf(path, "."));
	extension = substring(path, lastIndexOf(path, ".")+1, lengthOf(path));

	if(extension=="vol" || extension=="vgi"){
	  vgifile=File.openAsString(pathfile+".vgi");
	  rows=split(vgifile, "\n");

		r = 0;
		u = 0;
		for(i=0; i<rows.length; i++){
	    columns=split(rows[i],"=");

	    if (indexOf(columns[0], "size", 0)==0){
	      size = split(columns[1]," ");
	      sizeW=size[0];
	      sizeH=size[1];
	      sizeZ=size[2];
	    }

	    if (indexOf(columns[0], "bitsperelement", 0)==0){
	    	bitsize = split(columns[1]," ");
	      	bitsize = bitsize[0];
	    }

	    if (indexOf(columns[0], "datatype", 0)==0){
	    	datatype = split(columns[1]," ");
	    	datatype = datatype[0];

	      if (datatype=="float"){
	      		datatype = "Real";
	      	}
	      	else{
	      		datatype = "Unsigned";
	        }
	    }

			if ((indexOf(columns[0], "resolution", 0)==0)&(r==0)){
		    resolution = split(columns[1]," ");
		    voxelWidth=resolution[0];
		    voxelHeight=resolution[1];
		    voxelDepth=resolution[2];
		    r++;
	    }

	    if ((indexOf(columns[0], "unit", 0)==0)&(u==0)){
		    unit = split(columns[1]," ");
		    voxelUnit = unit[0];
		    u++;
	   }
	  }

	  filename = pathfile +".vol";
	  run("Raw...", "open='" + filename +"' image=[" + bitsize + "-bit " + datatype + "] width="+sizeW + " height="+sizeH + " number="+sizeZ +" little-endian use");
		run("Properties...", "channels=1 slices="+sizeZ+" frames=1 unit="+voxelUnit+" pixel_width="+voxelWidth+" pixel_height="+voxelHeight+" voxel_depth="+voxelDepth);
	}

	if(extension=="raw"){
	  settings=substring(path, lastIndexOf(path, "_")+1, lengthOf(path));
	  settings=split(settings, ".");
	  settings=split(settings[0], "[xX]");
	  sizeW=settings[0];
	  sizeH=settings[1];
	  sizeZ=settings[2];
	  bitsize=split(settings[3], "bit");
	  bitsize=bitsize[0];

	  filename = pathfile +".raw";
	  if (bitsize==8){
	    run("Raw...", "open='" + filename +"' image=[8-bit] width="+sizeW + " height="+sizeH + " number="+sizeZ +" big-endian use");
	  }else{
	    run("Raw...", "open='" + filename +"' image=["+ bitsize +"-bit Unsigned] width="+sizeW + " height="+sizeH + " number="+sizeZ +" big-endian use");
	  }
	}
}
