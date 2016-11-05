#!/bin/sh

# Outputs status code counts, sorted and total counts

# status code counts, sorted
docker exec -it random-status-nginx cat /var/log/nginx/random_status_access.log | \
  cut -d '"' -f3 | cut -d ' ' -f2 | sort | uniq -c | sort -rn

## status code counts, sorted, within date range
# docker exec -it random-status-nginx cat /var/log/nginx/random_status_access.log | \
#   sed -n '/05\/Nov\/2016:15:07:02/,/05\/Nov\/2016:15:07:07/ p' | \
#   cut -d '"' -f3 | cut -d ' ' -f2 | sort | uniq -c | sort -rn

# status code counts total
docker exec -it random-status-nginx cat /var/log/nginx/random_status_access.log | \
cut -d '"' -f3 | cut -d ' ' -f2 | echo $(wc -l) Total
