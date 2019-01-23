# By Jeff An | Source at https://github.com/jeff-an/docker-os161/
#!/usr/bin/env bash

echo "Docker OS161 Configuration Script"
if [ "$#" -ne 1 ]; then
    echo "Error: Illegal number of parameters"
    echo "Usage: ./bin/config ASSTX where X is your assignment number"
fi
if [ "$0" != "./bin/config.sh" ]; then
    echo "Error: Wrong working directory"
    echo "Usage: ./bin/config ASSTX where X is your assignment number"
fi
echo "Configuring for ASST$1..."
cd bin
for filename in ./*.sh; do
    if [ "$filename" != "./config.sh" ]; then
        shortname=${filename##*/}
        sed -i.bak "s/ASSIGNMENT=.*$/ASSIGNMENT=ASST$1/" $filename
        rm $filename.bak
    fi
done