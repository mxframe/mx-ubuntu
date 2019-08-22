# Load the bashrc includes
for filename in $HOME/bin/server-setup/includes/bashrc/*.sh
do
    . ${filename}
done
