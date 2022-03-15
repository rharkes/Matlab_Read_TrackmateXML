# Matlab_Read_TrackmateXML
Read TrackmateXML files in Matlab

# Examples
## Find start position of a track
```
txml = TrackmateXML(pth)
[start,finish,split,merge] = txml.analyse_track('Track_5')
[x,y] = txml.getspotXY(start)
```
