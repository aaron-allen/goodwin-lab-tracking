
for d in * ; do
    echo $d
    grep -R "${d}" ../_logs/failed_tracking/*  | sed 's/.*-failed_tracking.log://g' >> new_settings.txt
done
