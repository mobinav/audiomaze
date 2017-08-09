function str = ji_struct2json(S)
% struct2json  convert struct to serializable string
%
%   str = struct2json(S)
%
%   inelegantly calls saveJSONfile
%
% Example:
%     data.name = 'chair';
%     data.color = 'pink';
%     data.metrics.height = 0.3;
%     data.metrics.width = 1.3;
%     saveJSONfile(data, 'out.json');
%
% Output str = 
% {
% 	"name" : "chair",
% 	"color" : "pink",
% 	"metrics" : {
% 		"height" : 0.3,
% 		"width" : 1.3
% 		}
% 	}
%
fname = tempname;
saveJSONfile(S,fname);
fid = fopen(fname,'r');
str = char(fread(fid,inf,'char'))';
fclose(fid);
delete(fname);
    