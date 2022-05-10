function tmx = get_trackmateXML(pth_xml)
% If a .xml is requested, first check if there is a
% .mat file with the same base-name. If there is, open it and see if
% the MD5 hash corresponds to that of the requested xml.
% If it corresponds, return it. If not, open the xml and save as .mat

[pathstr, name, ext] = fileparts(pth_xml);
if ~strcmp(ext, '.xml')
    error('Request .xml file')
end
pth_mat = fullfile(pathstr, append(name,'.mat'));
if exist(pth_mat, 'file')==2
    % found .mat file, check if it is correct
    hash = TrackmateXML.getMD5(pth_xml);
    tmx = load(pth_mat);
    if isfield(tmx,'tmx')
        tmx = tmx.tmx;
        if isprop(tmx,'MD5')
            if strcmp(tmx.MD5, hash)
                return
            end
        end
    end
end
tmx = load_and_save(pth_xml, pth_mat);
end

function tmx = load_and_save(pth_xml, pth_mat)
disp('loading xml...')
tmx = TrackmateXML(pth_xml);
save(pth_mat, 'tmx')
end