function [densityMap, densityMapSupportX, densityMapSupportY] = ...
    computeDensityMap(obj, dataSource)

% Factor to convert rectangular grid density to hexagonal grid density
rectToHexDensityFactor = 2/sqrt(3.0);

% Make sampling grid
deltaX = 3 * obj.lambdaMin * 1e-6;
margin = 0 * obj.lambdaMin * 1e-6;


mosaicSize = 0.5*max([obj.width obj.height]);
gridXPos = 0:deltaX:(mosaicSize-margin);
gridXPos = cat(2,-fliplr(gridXPos), gridXPos(2:end));
gridYPos = gridXPos;
[densityMapSupportX,densityMapSupportY] = meshgrid(gridXPos, gridYPos);

if (strcmp(dataSource, 'from mosaic'))

    meanDistanceInMM = zeros(1,numel(densityMapSupportX));
    for iPos = 1:numel(densityMapSupportX)
        % Find the cone closest to the grid point
        gridPos = [densityMapSupportX(iPos) densityMapSupportY(iPos)];
        distances = sum(bsxfun(@minus, obj.coneLocsHexGrid, gridPos).^2,2);
        [~,targetConeIndex] = min(distances);

        % All the conex minus the target cone
        tmpConeLocs = obj.coneLocsHexGrid;
        tmpConeLocs(targetConeIndex,:) = nan;
        
        % Find the mean distances of the target cone to its 6 neighboring cones
        neigboringConesNum = 6;
        nearestConeDistancesInMeters = pdist2(tmpConeLocs, ...
            obj.coneLocsHexGrid(targetConeIndex,:), ...
            'Euclidean', 'Smallest', neigboringConesNum);

        meanDistanceInMM(1,iPos) = mean(nearestConeDistancesInMeters) * 1000;
    end

    fprintf('Min distance: %2.2f microns\n', min(meanDistanceInMM)*1000);
    
    densityMap = rectToHexDensityFactor * (1./meanDistanceInMM).^2;
    densityMap = reshape(densityMap, [size(densityMapSupportX,1) size(densityMapSupportX,2)]);

    hsize = 3;
    sigma = 1.6/3;
    smoothingKernel = fspecial('gaussian',hsize,sigma);
    densityMapSmoothed = conv2(densityMap, smoothingKernel, 'same');
    densityMap = densityMapSmoothed;
    [maxDensity, idx] = max(densityMap(:));
    [row,col] = ind2sub(size(densityMap), idx);
    fprintf('Max density: %2.0f cones/mm2 at %2.1f %2.1f\n', ...
        maxDensity, densityMapSupportX(idx)*1e6, densityMapSupportY(idx)*1e6);
%     figure(221);
%     imagesc(smoothingKernel)
%         axis 'image'
%     colormap(gray)
% 
%     figure(222); clf;
%     subplot(1,2,1)
%     imagesc(densityMap);
%     axis 'image';
%     colorbar
%     subplot(1,2,2)
%     imagesc(densityMapSmoothed);
%     axis 'image';
%     colormap(gray);
%     colorbar
%     pause
    
else
    eccInMeters = sqrt(densityMapSupportX .^ 2 + densityMapSupportY .^ 2);
    ang = atan2(densityMapSupportY, densityMapSupportX) / pi * 180;
    [~, ~, densities] = coneSizeReadData(...
        'eccentricity', eccInMeters(:), 'angle', ang(:));
    densityMap = rectToHexDensityFactor * reshape(densities, size(densityMapSupportX));
end
end
