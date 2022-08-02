
for d in * ; do
    echo $d
    grep -R "${d}" /mnt/data/Tracking/_logs/failed_tracking/*  | sed 's/.*-failed_tracking.log://g' >> new_settings.txt
done
