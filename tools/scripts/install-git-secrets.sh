#!/bin/bash

git secrets --install
git secrets --add 'network.local'
git secrets --add '([Jj]anuary|[Ff]ebuary|[Mm]arch|[Aa]pril|[Mm]ay|[Jj]une|[Jj]uly|[Aa]ugust|[Ss]eptember|[Oo]ctober|[Nn]ovember|[Dd]ecember)[0-9]{1,2}'
git secrets --add '192.168.0.[0-9]{,3}'
