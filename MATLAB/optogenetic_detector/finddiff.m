function numabovethresh=finddiff(avimg,im,th,xmin,xmax,ymin,ymax)
difference=im-avimg;
abovethresh=difference>th;
indicesabove=find(abovethresh(ymin:ymax,xmin:xmax));
numabovethresh=numel(indicesabove);
