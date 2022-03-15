# Matlab_Read_TrackmateXML
Read TrackmateXML files in Matlab

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
