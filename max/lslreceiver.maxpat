{
	"patcher" : 	{
		"fileversion" : 1,
		"rect" : [ 381.0, 44.0, 1139.0, 728.0 ],
		"bglocked" : 0,
		"defrect" : [ 381.0, 44.0, 1139.0, 728.0 ],
		"openrect" : [ 0.0, 0.0, 0.0, 0.0 ],
		"openinpresentation" : 0,
		"default_fontsize" : 12.0,
		"default_fontface" : 0,
		"default_fontname" : "Arial",
		"gridonopen" : 0,
		"gridsize" : [ 15.0, 15.0 ],
		"gridsnaponopen" : 0,
		"toolbarvisible" : 1,
		"boxanimatetime" : 200,
		"imprint" : 0,
		"enablehscroll" : 1,
		"enablevscroll" : 1,
		"devicewidth" : 0.0,
		"boxes" : [ 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "s noisePitchCtl",
					"fontsize" : 12.0,
					"numoutlets" : 0,
					"id" : "obj-62",
					"fontname" : "Arial",
					"numinlets" : 1,
					"patching_rect" : [ 849.0, 209.0, 90.0, 20.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "number",
					"fontsize" : 12.0,
					"numoutlets" : 2,
					"outlettype" : [ "int", "bang" ],
					"id" : "obj-61",
					"fontname" : "Arial",
					"numinlets" : 1,
					"patching_rect" : [ 836.0, 165.0, 50.0, 20.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "lslreceive 2 noisepitch",
					"fontsize" : 12.0,
					"numoutlets" : 3,
					"outlettype" : [ "list", "float", "float" ],
					"id" : "obj-4",
					"fontname" : "Arial",
					"numinlets" : 1,
					"patching_rect" : [ 820.0, 60.0, 128.0, 20.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "unpack s",
					"fontsize" : 12.0,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"id" : "obj-59",
					"fontname" : "Arial",
					"numinlets" : 1,
					"patching_rect" : [ 822.0, 93.0, 59.0, 20.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "fromsymbol",
					"fontsize" : 12.0,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"id" : "obj-60",
					"fontname" : "Arial",
					"numinlets" : 1,
					"patching_rect" : [ 829.0, 131.0, 73.0, 20.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "message",
					"text" : "2 180 away",
					"fontsize" : 12.0,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"id" : "obj-58",
					"fontname" : "Arial",
					"numinlets" : 2,
					"patching_rect" : [ 685.0, 423.0, 72.0, 18.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "Use these to test beacon sounds",
					"linecount" : 3,
					"fontsize" : 12.0,
					"numoutlets" : 0,
					"id" : "obj-57",
					"fontname" : "Arial",
					"numinlets" : 1,
					"patching_rect" : [ 26.0, 164.0, 82.0, 48.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "Use these to test maze sounds",
					"linecount" : 3,
					"fontsize" : 12.0,
					"numoutlets" : 0,
					"id" : "obj-54",
					"fontname" : "Arial",
					"numinlets" : 1,
					"patching_rect" : [ 676.0, 209.0, 82.0, 48.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "message",
					"text" : "1 180 firsttouch",
					"linecount" : 2,
					"fontsize" : 12.0,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"id" : "obj-53",
					"fontname" : "Arial",
					"numinlets" : 2,
					"patching_rect" : [ 689.0, 375.0, 59.0, 32.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "Receive lsl messages from matlab & send lsl events\n\ne:\\demo\\AudioMazeLSL\\Run_AudioMaze.m\non presenting pc",
					"linecount" : 9,
					"fontsize" : 12.0,
					"numoutlets" : 0,
					"id" : "obj-44",
					"fontname" : "Arial",
					"numinlets" : 1,
					"patching_rect" : [ 3.0, 6.0, 103.0, 131.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "fromsymbol",
					"fontsize" : 12.0,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"id" : "obj-42",
					"fontname" : "Arial",
					"numinlets" : 1,
					"patching_rect" : [ 119.0, 95.0, 73.0, 20.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "number",
					"fontsize" : 12.0,
					"numoutlets" : 2,
					"outlettype" : [ "int", "bang" ],
					"id" : "obj-41",
					"fontname" : "Arial",
					"numinlets" : 1,
					"patching_rect" : [ 119.0, 132.0, 50.0, 20.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "print Event_Code",
					"fontsize" : 12.0,
					"numoutlets" : 0,
					"id" : "obj-40",
					"fontname" : "Arial",
					"numinlets" : 1,
					"patching_rect" : [ 280.0, 445.0, 103.0, 20.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "lslsendevent",
					"fontsize" : 12.0,
					"numoutlets" : 0,
					"id" : "obj-30",
					"fontname" : "Arial",
					"numinlets" : 1,
					"patching_rect" : [ 246.0, 470.0, 77.0, 20.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "r Event_Code",
					"fontsize" : 12.0,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"id" : "obj-39",
					"fontname" : "Arial",
					"numinlets" : 0,
					"patching_rect" : [ 246.0, 420.0, 84.0, 20.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "lslreceive 3 handproximity",
					"fontsize" : 12.0,
					"numoutlets" : 3,
					"outlettype" : [ "list", "float", "float" ],
					"id" : "obj-28",
					"fontname" : "Arial",
					"numinlets" : 1,
					"patching_rect" : [ 496.0, 4.0, 149.0, 20.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "unpack s s s",
					"fontsize" : 12.0,
					"numoutlets" : 3,
					"outlettype" : [ "", "", "" ],
					"id" : "obj-27",
					"fontname" : "Arial",
					"numinlets" : 1,
					"patching_rect" : [ 498.0, 37.0, 77.0, 20.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "toggle",
					"numoutlets" : 1,
					"outlettype" : [ "int" ],
					"id" : "obj-10",
					"numinlets" : 1,
					"patching_rect" : [ 245.0, 297.0, 20.0, 20.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "print fileplay",
					"fontsize" : 12.0,
					"numoutlets" : 0,
					"id" : "obj-14",
					"fontname" : "Arial",
					"numinlets" : 1,
					"patching_rect" : [ 245.0, 360.0, 75.0, 20.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "gate",
					"fontsize" : 12.0,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"id" : "obj-26",
					"fontname" : "Arial",
					"numinlets" : 2,
					"patching_rect" : [ 245.0, 330.0, 34.0, 20.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "flonum",
					"fontsize" : 12.0,
					"numoutlets" : 2,
					"outlettype" : [ "float", "bang" ],
					"id" : "obj-22",
					"fontname" : "Arial",
					"numinlets" : 1,
					"patching_rect" : [ 507.0, 131.0, 50.0, 20.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "message",
					"fontsize" : 11.595187,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"id" : "obj-20",
					"fontname" : "Arial",
					"numinlets" : 2,
					"patching_rect" : [ 628.0, 132.0, 73.0, 18.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "message",
					"text" : "beacon1",
					"fontsize" : 11.595187,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"id" : "obj-19",
					"fontname" : "Arial",
					"numinlets" : 2,
					"patching_rect" : [ 399.0, 134.0, 64.0, 18.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "fromsymbol",
					"fontsize" : 12.0,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"id" : "obj-12",
					"fontname" : "Arial",
					"numinlets" : 1,
					"patching_rect" : [ 565.0, 100.0, 73.0, 20.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "fromsymbol",
					"fontsize" : 12.0,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"id" : "obj-11",
					"fontname" : "Arial",
					"numinlets" : 1,
					"patching_rect" : [ 505.0, 75.0, 73.0, 20.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "fromsymbol",
					"fontsize" : 12.0,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"id" : "obj-9",
					"fontname" : "Arial",
					"numinlets" : 1,
					"patching_rect" : [ 339.0, 75.0, 73.0, 20.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "fromsymbol",
					"fontsize" : 12.0,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"id" : "obj-8",
					"fontname" : "Arial",
					"numinlets" : 1,
					"patching_rect" : [ 289.0, 101.0, 73.0, 20.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "fromsymbol",
					"fontsize" : 12.0,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"id" : "obj-7",
					"fontname" : "Arial",
					"numinlets" : 1,
					"patching_rect" : [ 245.0, 73.0, 73.0, 20.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "fromsymbol",
					"fontsize" : 12.0,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"id" : "obj-5",
					"fontname" : "Arial",
					"numinlets" : 1,
					"patching_rect" : [ 192.0, 98.0, 73.0, 20.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "JRI 12/19/13\nreceiver for LSL stream\nfileplay -> fileplay.poly\nhandproximity -> LSLMazewpoly",
					"linecount" : 4,
					"fontsize" : 12.0,
					"numoutlets" : 0,
					"id" : "obj-3",
					"fontname" : "Arial",
					"numinlets" : 1,
					"patching_rect" : [ 427.0, 385.0, 193.0, 62.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "message",
					"text" : "\"1\" \"1\" \"1\" \"135\" \"110\" beacon1",
					"linecount" : 2,
					"fontsize" : 12.0,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"id" : "obj-1",
					"fontname" : "Arial",
					"numinlets" : 2,
					"patching_rect" : [ 117.0, 34.0, 96.0, 32.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "message",
					"text" : "0.5 180 halfway",
					"linecount" : 2,
					"fontsize" : 12.0,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"id" : "obj-56",
					"fontname" : "Arial",
					"numinlets" : 2,
					"patching_rect" : [ 689.0, 324.0, 54.0, 32.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "message",
					"text" : "0 180 inwall",
					"linecount" : 2,
					"fontsize" : 12.0,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"id" : "obj-55",
					"fontname" : "Arial",
					"numinlets" : 2,
					"patching_rect" : [ 698.0, 269.0, 44.0, 32.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "pack 0. 0 s",
					"fontsize" : 12.0,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"id" : "obj-48",
					"fontname" : "Arial",
					"numinlets" : 3,
					"patching_rect" : [ 547.0, 223.0, 70.0, 20.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "s handproximity",
					"fontsize" : 12.0,
					"numoutlets" : 0,
					"id" : "obj-49",
					"fontname" : "Arial",
					"numinlets" : 1,
					"patching_rect" : [ 547.0, 272.0, 95.0, 20.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "toggle",
					"numoutlets" : 1,
					"outlettype" : [ "int" ],
					"id" : "obj-45",
					"numinlets" : 1,
					"patching_rect" : [ 448.0, 255.0, 20.0, 20.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "print handproximity",
					"fontsize" : 12.0,
					"numoutlets" : 0,
					"id" : "obj-46",
					"fontname" : "Arial",
					"numinlets" : 1,
					"patching_rect" : [ 448.0, 318.0, 112.0, 20.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "gate",
					"fontsize" : 12.0,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"id" : "obj-47",
					"fontname" : "Arial",
					"numinlets" : 2,
					"patching_rect" : [ 448.0, 288.0, 34.0, 20.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "handEvent",
					"fontsize" : 9.0,
					"numoutlets" : 0,
					"id" : "obj-52",
					"fontname" : "Arial",
					"numinlets" : 1,
					"patching_rect" : [ 624.0, 159.0, 62.0, 17.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "handAzi",
					"fontsize" : 9.0,
					"numoutlets" : 0,
					"id" : "obj-51",
					"fontname" : "Arial",
					"numinlets" : 1,
					"patching_rect" : [ 567.0, 157.0, 50.0, 17.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "handDist",
					"fontsize" : 9.0,
					"numoutlets" : 0,
					"id" : "obj-50",
					"fontname" : "Arial",
					"numinlets" : 1,
					"patching_rect" : [ 509.0, 158.0, 50.0, 17.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "eventCode",
					"fontsize" : 9.0,
					"numoutlets" : 0,
					"id" : "obj-43",
					"fontname" : "Arial",
					"numinlets" : 1,
					"patching_rect" : [ 398.0, 158.0, 53.0, 17.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "volume",
					"fontsize" : 9.0,
					"numoutlets" : 0,
					"id" : "obj-37",
					"fontname" : "Arial",
					"numinlets" : 1,
					"patching_rect" : [ 347.0, 158.0, 50.0, 17.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "azimuth",
					"fontsize" : 9.0,
					"numoutlets" : 0,
					"id" : "obj-35",
					"fontname" : "Arial",
					"numinlets" : 1,
					"patching_rect" : [ 293.0, 159.0, 50.0, 17.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "loop",
					"fontsize" : 9.0,
					"numoutlets" : 0,
					"id" : "obj-33",
					"fontname" : "Arial",
					"numinlets" : 1,
					"patching_rect" : [ 240.0, 160.0, 50.0, 17.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "sound ON",
					"fontsize" : 9.0,
					"numoutlets" : 0,
					"id" : "obj-31",
					"fontname" : "Arial",
					"numinlets" : 1,
					"patching_rect" : [ 185.0, 160.0, 50.0, 17.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "sound  ID",
					"fontsize" : 9.0,
					"numoutlets" : 0,
					"id" : "obj-29",
					"fontname" : "Arial",
					"numinlets" : 1,
					"patching_rect" : [ 118.0, 156.0, 50.0, 17.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "number",
					"fontsize" : 12.0,
					"numoutlets" : 2,
					"outlettype" : [ "int", "bang" ],
					"id" : "obj-25",
					"fontname" : "Arial",
					"numinlets" : 1,
					"patching_rect" : [ 565.0, 134.0, 50.0, 20.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "unpack s s s s s s",
					"fontsize" : 12.0,
					"numoutlets" : 6,
					"outlettype" : [ "", "", "", "", "", "" ],
					"id" : "obj-21",
					"fontname" : "Arial",
					"numinlets" : 1,
					"patching_rect" : [ 250.0, 33.0, 105.0, 20.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "lslreceive 6 fileplay",
					"fontsize" : 12.0,
					"numoutlets" : 3,
					"outlettype" : [ "list", "float", "float" ],
					"id" : "obj-2",
					"fontname" : "Arial",
					"numinlets" : 1,
					"patching_rect" : [ 265.0, 2.0, 111.0, 20.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "message",
					"text" : "3 0 0 135 110 3",
					"fontsize" : 12.0,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"id" : "obj-18",
					"fontname" : "Arial",
					"numinlets" : 2,
					"patching_rect" : [ 32.0, 368.0, 94.0, 18.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "message",
					"text" : "1 0 0 135 110 beacon1off",
					"fontsize" : 12.0,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"id" : "obj-17",
					"fontname" : "Arial",
					"numinlets" : 2,
					"patching_rect" : [ 36.0, 333.0, 146.0, 18.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "message",
					"text" : "1 1 1 135 110 beacon1",
					"fontsize" : 12.0,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"id" : "obj-16",
					"fontname" : "Arial",
					"numinlets" : 2,
					"patching_rect" : [ 35.0, 301.0, 132.0, 18.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "message",
					"text" : "2 1 1 135 110 beacon2",
					"fontsize" : 12.0,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"id" : "obj-15",
					"fontname" : "Arial",
					"numinlets" : 2,
					"patching_rect" : [ 35.0, 273.0, 132.0, 18.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "message",
					"text" : "2 0 0 0 0 off",
					"fontsize" : 12.0,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"id" : "obj-13",
					"fontname" : "Arial",
					"numinlets" : 2,
					"patching_rect" : [ 45.0, 241.0, 74.0, 18.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "message",
					"text" : "3 1 0 135 110 beacon3",
					"fontsize" : 12.0,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"id" : "obj-6",
					"fontname" : "Arial",
					"numinlets" : 2,
					"patching_rect" : [ 33.0, 216.0, 132.0, 18.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "number",
					"fontsize" : 12.0,
					"numoutlets" : 2,
					"outlettype" : [ "int", "bang" ],
					"id" : "obj-38",
					"fontname" : "Arial",
					"numinlets" : 1,
					"patching_rect" : [ 183.0, 134.0, 50.0, 20.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "number",
					"fontsize" : 12.0,
					"numoutlets" : 2,
					"outlettype" : [ "int", "bang" ],
					"id" : "obj-36",
					"fontname" : "Arial",
					"numinlets" : 1,
					"patching_rect" : [ 237.0, 134.0, 50.0, 20.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "number",
					"fontsize" : 12.0,
					"numoutlets" : 2,
					"outlettype" : [ "int", "bang" ],
					"id" : "obj-34",
					"fontname" : "Arial",
					"numinlets" : 1,
					"patching_rect" : [ 292.0, 133.0, 50.0, 20.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "number",
					"fontsize" : 12.0,
					"numoutlets" : 2,
					"outlettype" : [ "int", "bang" ],
					"id" : "obj-32",
					"fontname" : "Arial",
					"numinlets" : 1,
					"patching_rect" : [ 344.0, 134.0, 50.0, 20.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "pack 0 0 0 0 0 s",
					"fontsize" : 12.0,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"id" : "obj-24",
					"fontname" : "Arial",
					"numinlets" : 6,
					"patching_rect" : [ 209.0, 201.0, 95.0, 20.0 ]
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "s fileplay",
					"fontsize" : 12.0,
					"numoutlets" : 0,
					"id" : "obj-23",
					"fontname" : "Arial",
					"numinlets" : 1,
					"patching_rect" : [ 277.0, 235.0, 57.0, 20.0 ]
				}

			}
 ],
		"lines" : [ 			{
				"patchline" : 				{
					"source" : [ "obj-61", 0 ],
					"destination" : [ "obj-62", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-60", 0 ],
					"destination" : [ "obj-61", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-4", 0 ],
					"destination" : [ "obj-59", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-59", 0 ],
					"destination" : [ "obj-60", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-39", 0 ],
					"destination" : [ "obj-40", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-39", 0 ],
					"destination" : [ "obj-30", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-56", 0 ],
					"destination" : [ "obj-49", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-55", 0 ],
					"destination" : [ "obj-49", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-45", 0 ],
					"destination" : [ "obj-47", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-6", 0 ],
					"destination" : [ "obj-23", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-13", 0 ],
					"destination" : [ "obj-23", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-15", 0 ],
					"destination" : [ "obj-23", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-16", 0 ],
					"destination" : [ "obj-23", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-17", 0 ],
					"destination" : [ "obj-23", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-18", 0 ],
					"destination" : [ "obj-23", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-5", 0 ],
					"destination" : [ "obj-38", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-7", 0 ],
					"destination" : [ "obj-36", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-8", 0 ],
					"destination" : [ "obj-34", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-9", 0 ],
					"destination" : [ "obj-32", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-11", 0 ],
					"destination" : [ "obj-22", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-12", 0 ],
					"destination" : [ "obj-25", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-10", 0 ],
					"destination" : [ "obj-26", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-47", 0 ],
					"destination" : [ "obj-46", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-26", 0 ],
					"destination" : [ "obj-14", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-21", 4 ],
					"destination" : [ "obj-9", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-21", 3 ],
					"destination" : [ "obj-8", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-21", 2 ],
					"destination" : [ "obj-7", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-21", 1 ],
					"destination" : [ "obj-5", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-21", 5 ],
					"destination" : [ "obj-19", 1 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-2", 0 ],
					"destination" : [ "obj-21", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-2", 0 ],
					"destination" : [ "obj-1", 1 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-28", 0 ],
					"destination" : [ "obj-27", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-27", 0 ],
					"destination" : [ "obj-11", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-27", 1 ],
					"destination" : [ "obj-12", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-27", 2 ],
					"destination" : [ "obj-20", 1 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-27", 2 ],
					"destination" : [ "obj-48", 2 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-22", 0 ],
					"destination" : [ "obj-48", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-25", 0 ],
					"destination" : [ "obj-48", 1 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-48", 0 ],
					"destination" : [ "obj-49", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-48", 0 ],
					"destination" : [ "obj-47", 1 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-21", 0 ],
					"destination" : [ "obj-42", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-42", 0 ],
					"destination" : [ "obj-41", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-24", 0 ],
					"destination" : [ "obj-26", 1 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-24", 0 ],
					"destination" : [ "obj-23", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-38", 0 ],
					"destination" : [ "obj-24", 1 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-36", 0 ],
					"destination" : [ "obj-24", 2 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-34", 0 ],
					"destination" : [ "obj-24", 3 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-32", 0 ],
					"destination" : [ "obj-24", 4 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-21", 5 ],
					"destination" : [ "obj-24", 5 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-41", 0 ],
					"destination" : [ "obj-24", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-53", 0 ],
					"destination" : [ "obj-49", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-58", 0 ],
					"destination" : [ "obj-49", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
 ]
	}

}
