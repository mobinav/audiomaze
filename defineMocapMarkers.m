function X = defineMocapMarkers(X)

% set up marker indexes
%sensor numbers will depend on the phasespace profile used

defaultProfile = 'Audiomaze Suit';

if ~isfield(X,'phasespaceProfile'),
    X.phasespaceProfile = defaultProfile;
end

switch lower(X.phasespaceProfile),
    
    case 'audiomaze suit'
        %% "Audiomaze Suit" configuration (Feb, 2017--optimized 480Hz)
        X.mocap.markers.phasespaceProfile = 'Audiomaze Suit';
        X.mocap.markers.head = 1:4; %headCenter al, ar, pl, pr
        X.mocap.markers.headOrientation = 5:7; %L-Nose-R
        X.mocap.markers.rightHand = 16:19; %NB ignoring hand back marker as we care about fingertip touch
        X.mocap.markers.leftHand = [];
        
    case 'audiomaze head7 & hand'
        X.mocap.markers.phasespaceProfile = 'Audiomaze Head7 & Hand';
        X.mocap.markers.head = 1:4; %headCenter al, ar, pl, pr
        X.mocap.markers.headOrientation = 5:7; %L-Nose-R
        X.mocap.markers.rightHand = 8:11; %four fingertips
        X.mocap.markers.leftHand = [];
        
    case 'audiomaze head4 & hand'
        X.mocap.markers.phasespaceProfile = 'Audiomaze Head4 & Hand';
        X.mocap.markers.head = 1:4; %headCenter al, ar, pl, pr
        X.mocap.markers.headOrientation = []; %L-Nose-R
        X.mocap.markers.rightHand = 5:8; %four fingertips
        X.mocap.markers.leftHand = [];
        
        %% "Full Body 1 with DG (48)" configuration
        %mr.mocap.markers.phasespaceConfiguration = 'Full Body 1 with DG (48)';
        %mr.mocap.markers.head = [1:3 47];
        %mr.mocap.markers.rightHand = 11:18;
        %mr.mocap.markers.leftHand = 23:30;
        
        %% "Audiomaze-2" configuration
        %X.mocap.markers.phasespaceConfiguration = 'Audiomaze-2';
        %X.mocap.markers.head = 1:4;
        %X.mocap.markers.rightHand = 5:12;
        %X.mocap.markers.leftHand = 16:23;
        
        %% "audiomaze suit" configuration
        %X.mocap.markers.phasespaceConfiguration = 'audiomaze suit';
        %X.mocap.markers.head = 1:4;
        %X.mocap.markers.rightHand = 21:28;
        %X.mocap.markers.leftHand = 33:40;
    otherwise
        error(['Unrecognized phasespace profile: ' X.phasespaceProfile])
end