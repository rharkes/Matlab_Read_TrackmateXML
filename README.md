# Matlab_Read_TrackmateXML
Read TrackmateXML files in Matlab using [`readtable`](https://nl.mathworks.com/help/matlab/ref/readtable.html) introduced in [Matlab R2021a](https://nl.mathworks.com/help/matlab/release-notes.html?rntext=&startrelease=R2021a&endrelease=R2021a).

# Examples
## Read a TrackmateXML
```
txml = TrackmateXML(pth)
```
Reading takes 4 seconds for a 27.3MB TrackmateXML file with 112 tracks, 14055 edges and 40253 spots.
## Find the start location for track 5
```
[start,finish,split,merge] = txml.analyse_track('Track_5')
[x,y] = txml.getspotXY(start)
```
## Plot the intensity trace for track 0
```
track1 = tmx.getTrack('Track_0', false);  % don't duplicate the track before a split
clf
hold on
for i = 1:length(track1)
    I = tmx.getColumn(track1{i}, 'MEAN_INTENSITY_1');
    f = tmx.getColumn(track1{i}, 'FRAME');
    plot(f,I,'.-')
end
hold off
```
