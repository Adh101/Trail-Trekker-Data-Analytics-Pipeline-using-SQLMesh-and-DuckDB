#Set up the environment
cd "/Users/atishdhamala/Trail Trekker Data Pipeline/trail-trekker"

#Activate the virtual environment
source "../.venv/bin/activate"

#Run SQLMesh with logging enabled
echo "$(date): Starting the SQLmesh run..." >> ~/sqlmesh_cron.log
sqlmesh -p "/Users/atishdhamala/Trail Trekker Data Pipeline/trail-trekker" run prod >> ~/sqlmesh_cron.log 2>&1
echo "$(date): SQLmesh run completed." >> ~/sqlmesh_cron.log