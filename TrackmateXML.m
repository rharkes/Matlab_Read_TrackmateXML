classdef TrackmateXML
    %TRACKMATEXML Summary of this class goes here
    %   Detailed explanation goes here
    properties
        pth
        spots
        tracks
        filteredtracks
    end

    methods
        function obj = TrackmateXML(pth_in)
            %TRACKMATEXML Construct an instance of this class
            %   Detailed explanation goes here
            if nargin<1
                pth_in = 'C:\GitLabReps\pip-fucci-main\example\MAX_200506_TTFields Wee1 Inh U251 AZD1775.xml';
            end
            obj.pth = pth_in;
            spotopts = xmlImportOptions('VariableNames',{'ID','FRAME','POSITION_X', 'POSITION_Y', 'MEAN_INTENSITY_1', 'MEAN_INTENSITY_2', 'MEAN_INTENSITY_3', 'ESTIMATED_DIAMETER'},...
                'VariableTypes', {'int32', 'int32', 'double', 'double', 'double', 'double', 'double', 'double'},...
                'VariableSelectors',{ ...
                '/TrackMate/Model/AllSpots/SpotsInFrame/Spot/@ID', ...
                '/TrackMate/Model/AllSpots/SpotsInFrame/Spot/@FRAME', ...
                '/TrackMate/Model/AllSpots/SpotsInFrame/Spot/@POSITION_X' , ...
                '/TrackMate/Model/AllSpots/SpotsInFrame/Spot/@POSITION_Y', ...
                '/TrackMate/Model/AllSpots/SpotsInFrame/Spot/@MEAN_INTENSITY01',...
                '/TrackMate/Model/AllSpots/SpotsInFrame/Spot/@MEAN_INTENSITY02',...
                '/TrackMate/Model/AllSpots/SpotsInFrame/Spot/@MEAN_INTENSITY03',...
                '/TrackMate/Model/AllSpots/SpotsInFrame/Spot/@ESTIMATED_DIAMETER'});
            trackopts = xmlImportOptions('VariableNames',{'NUMBER_SPOTS','NAME'},...
                'VariableTypes', {'int32','char'},...
                'VariableSelectors',{ ...
                '/TrackMate/Model/AllTracks/Track/@NUMBER_SPOTS', ...
                '/TrackMate/Model/AllTracks/Track/@name'});
            edgeopts = xmlImportOptions('VariableNames',{'SOURCE_ID','TARGET_ID'},...
                'VariableTypes', {'int32','int32'},...
                'VariableSelectors',{ ...
                '/TrackMate/Model/AllTracks/Track/Edge/@SPOT_SOURCE_ID', ...
                '/TrackMate/Model/AllTracks/Track/Edge/@SPOT_TARGET_ID'});
            filteredtrackopts = xmlImportOptions('VariableNames',{'TRACK_ID'},...
                'VariableTypes', {'int32'},...
                'VariableSelectors',{'/TrackMate/Model/FilteredTracks/TrackID/@TRACK_ID'});
            obj.spots = readtable(pth_in, spotopts);
            tracklengths = readtable(pth_in,trackopts);
            alledges = readtable(pth_in,edgeopts);
            obj.filteredtracks = readtable(pth_in, filteredtrackopts);
            ntracks = height(tracklengths);
            obj.tracks = cell(ntracks,2);
            i=1;
            for ct = 1:ntracks
                tl = tracklengths.NUMBER_SPOTS(ct)-1;
                obj.tracks{ct,1}=tracklengths.NAME(ct);
                obj.tracks{ct,2}=alledges(i:(i+tl-1),:);
                i=i+tl;
            end
        end
        function [spotIDs] = getTrack(obj, trackID, duplicate_split)
            if nargin==2
                duplicate_split=true;
            end
            if isnumeric(trackID)
                track = obj.tracks{trackID,2};
                sources = track.SOURCE_ID;
                targets = track.TARGET_ID;
                start = setdiff(sources, targets);
                spotIDs{1} = [start];
                trackL = [0];
                while ~all(trackL == cellfun(@(x) length(x), spotIDs))
                    trackL = cellfun(@(x) length(x), spotIDs);
                    spotIDs = obj.traceTrack(sources, targets, spotIDs, duplicate_split);
                end
            else
                trackID = find(cellfun(@(c) strcmp(c,trackID), obj.tracks(:,1)));
                if isempty(trackID)
                    disp("Track not found")
                    spotIDs=[];
                    return
                end
                [spotIDs] = getTrack(obj, trackID, duplicate_split);
            end
        end
        function [I] = getColumn(obj, spotIDs, colname)
            allI = obj.spots{:,colname};
            I = zeros(length(spotIDs),1);
            for i = 1:length(spotIDs)
                I(i) = allI(obj.spots.ID==spotIDs(i));
            end
        end
        function [start, finish, splits, merges] = analyse_track(obj, trackID)
            if isnumeric(trackID)
                track = obj.tracks{trackID,2};
                sources = track.SOURCE_ID;
                targets = track.TARGET_ID;
                start = setdiff(sources, targets);
                finish = setdiff(targets,sources);
                [uniquevals, ~, ia] = unique(sources, 'stable');
                bincounts = accumarray(ia, 1);
                splits = uniquevals(ia(bincounts>1));
                [uniquevals, ~, ia] = unique(targets, 'stable');
                bincounts = accumarray(ia, 1);
                merges = uniquevals(ia(bincounts>1));
            else
                trackID = find(cellfun(@(c) strcmp(c,trackID), obj.tracks(:,1)));
                if isempty(trackID)
                    disp("Track not found")
                    start=[];finish=[];splits=[];merges=[];
                    return
                end
                [start, finish, splits, merges] = obj.analyse_track(trackID);
            end
        end
        function spot = getspot(obj, spotID)
            spot = obj.spots(find(obj.spots.ID==spotID),:);
        end
        function [x,y] = getspotXY(obj, spotID)
            spot = obj.getspot(spotID);
            x = spot.POSITION_X;
            y = spot.POSITION_Y;
        end
        function nEdges = getNedges(obj)
            nEdges=sum(cellfun(@(x) size(x,1),obj.tracks(:,2)));
        end
    end
    methods(Static)
        function [spotIDs] = traceTrack(sources, targets, spotIDs, duplicate_split)
            for i = 1:length(spotIDs)
                sid = spotIDs{i};
                target = targets(sources==sid(end));
                if isempty(target)
                    continue
                elseif length(target)==1
                    sid(end+1) = target;
                else
                    for j = 2:length(target)
                        if duplicate_split
                            spotIDs{end+1} = [sid, target(j)];
                        else
                            spotIDs{end+1} = [target(j)];
                        end
                    end
                    sid(end+1) = target(1);
                end
                spotIDs{i} = sid;
            end
        end
    end
end
