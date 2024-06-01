function lsblko --wraps='lsblk -o NAME,UUID,FSTYPE,FSUSE%,LABEL' --description 'alias lsblko=lsblk -o NAME,UUID,FSTYPE,FSUSE%,LABEL'
    lsblk -o NAME,UUID,FSTYPE,FSUSE%,LABEL $argv
end
