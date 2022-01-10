function numabovethresh = finddiff(avimg, im, th, ymin, ymax, xmin, xmax)
difference = im - avimg;
abovethresh = difference > (3 * th);
indicesabove = find(abovethresh(xmin:xmax, ymin:ymax));
numabovethresh = numel(indicesabove);
