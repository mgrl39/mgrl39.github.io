#!/bin/bash

# Definición de colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
NC='\033[0m' # Sin color

# Función para mostrar el resultado con colores
function print_result() {
    local message=$1
    local status=$2
    case $status in
        "OK")
            echo -e "${GREEN}$message${NC}"
            ;;
        "WARN")
            echo -e "${RED}$message${NC}"
            ;;
        "INFO")
            echo -e "${YELLOW}$message${NC}"
            ;;
        "TITLE")
            echo -e "${PURPLE}$message${NC}"
            ;;
    esac
}

# Verificar si hay 3 particiones LVM con home, root como ext4 y swap
check_lvm_partitions() {
    print_result "Verificando particiones LVM..." "TITLE"
    lvm_count=$(lsblk -o TYPE | grep -c "lvm")
    if [ "$lvm_count" -eq 3 ]; then
        print_result "3 particiones LVM encontradas." "OK"
    else
        print_result "Advertencia: No se encontraron 3 particiones LVM." "WARN"
    fi

    if lsblk -f | grep -q "home" && lsblk -f | grep "home" | grep -q "ext4"; then
        print_result "Partición home encontrada como ext4." "OK"
    else
        print_result "Advertencia: Partición home no encontrada o no es ext4." "WARN"
    fi

    if lsblk -f | grep -q "root" && lsblk -f | grep "root" | grep -q "ext4"; then
        print_result "Partición root encontrada como ext4." "OK"
    else
        print_result "Advertencia: Partición root no encontrada o no es ext4." "WARN"
    fi

    if lsblk -f | grep -q "swap"; then
        print_result "Partición swap encontrada." "OK"
    else
        print_result "Advertencia: Partición swap no encontrada." "WARN"
    fi
}

# Verificar si está instalado sudo, si existe el grupo user42, y si el usuario 1000 está en el grupo
check_sudo_user42() {
    print_result "Verificando sudo, user42 y usuario 1000..." "TITLE"

    if dpkg -l | grep -q "sudo"; then
        print_result "sudo está instalado." "OK"
    else
        print_result "Advertencia: sudo no está instalado." "WARN"
    fi

    if grep -q "^user42:" /etc/group; then
        print_result "Grupo user42 existe." "OK"
        user_1000=$(getent passwd | awk -F: '$3 == 1000 {print $1}')
        if [ -n "$user_1000" ] && id -nG "$user_1000" | grep -qw "user42"; then
            print_result "El usuario con ID 1000 ($user_1000) está en el grupo user42." "OK"
        else
            print_result "Advertencia: El usuario con ID 1000 no está en el grupo user42." "WARN"
        fi
    else
        print_result "Advertencia: Grupo user42 no existe." "WARN"
    fi

    if [ -n "$user_1000" ] && id -nG "$user_1000" | grep -qw "sudo"; then
        print_result "El usuario con ID 1000 está en el grupo sudo." "OK"
    else
        print_result "Advertencia: El usuario con ID 1000 no está en el grupo sudo." "WARN"
    fi
}

# Verificar si está instalado openssh-server, si el servicio está activo, y revisar sshd_config y ssh_config
check_openssh() {
    print_result "Verificando openssh-server y configuración SSH..." "TITLE"

    if dpkg -l | grep -q "openssh-server"; then
        print_result "openssh-server está instalado." "OK"
        ssh_status=$(systemctl is-active ssh)
        if [ "$ssh_status" = "active" ]; then
            print_result "El servicio ssh está activo." "OK"
        else
            print_result "Advertencia: El servicio ssh no está activo." "WARN"
        fi

        sshd_config="/etc/ssh/sshd_config"
        if grep -q "^Port 4242" "$sshd_config" && grep -q "^PermitRootLogin no" "$sshd_config"; then
            print_result "sshd_config está configurado correctamente (Port 4242, PermitRootLogin no)." "OK"
        else
            print_result "Advertencia: sshd_config no está configurado correctamente." "WARN"
        fi

        ssh_config="/etc/ssh/ssh_config"
        if grep -q "^Port 4242" "$ssh_config"; then
            print_result "ssh_config está configurado con Port 4242." "OK"
        else
            print_result "Advertencia: ssh_config no está configurado con Port 4242." "WARN"
        fi
    else
        print_result "Advertencia: openssh-server no está instalado." "WARN"
    fi
}

# Verificar si ufw está instalado, habilitado, y si el puerto 4242 está permitido
check_ufw() {
    print_result "Verificando UFW..." "TITLE"

    if dpkg -l | grep -q "ufw"; then
        print_result "UFW está instalado." "OK"
        ufw_status=$(sudo ufw status | grep -q "Status: active")
        if [ "$?" -eq 0 ]; then
            print_result "UFW está habilitado." "OK"
        else
            print_result "Advertencia: UFW no está habilitado." "WARN"
        fi

        if sudo ufw status | grep -q "4242"; then
            print_result "El puerto 4242 está permitido en UFW." "OK"
        else
            print_result "Advertencia: El puerto 4242 no está permitido en UFW." "WARN"
        fi
    else
        print_result "Advertencia: UFW no está instalado." "WARN"
    fi
}

# Verificar configuración de sudo en /etc/sudoers
check_sudoers_config() {
    print_result "Verificando configuración de sudo en /etc/sudoers.d/sudo_config..." "TITLE"

    sudoers_config="/etc/sudoers.d/sudo_config"
    if grep -q "Defaults  passwd_tries=3" "$sudoers_config" &&
       grep -q 'Defaults  badpass_message="*"' "$sudoers_config" &&
       grep -q 'Defaults  logfile="/var/log/sudo/sudo_config"' "$sudoers_config" &&
       grep -q "Defaults  log_input, log_output" "$sudoers_config" &&
       grep -q 'Defaults  iolog_dir="/var/log/sudo"' "$sudoers_config" &&
       grep -q "Defaults  requiretty" "$sudoers_config" &&
       grep -q 'Defaults  secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"' "$sudoers_config"; then
        print_result "Configuración de sudoers es correcta." "OK"
    else
        print_result "Advertencia: Configuración de sudoers no es correcta." "WARN"
    fi
}

# Verificar configuración en /etc/login.defs
check_login_defs() {
    print_result "Verificando configuración en /etc/login.defs..." "TITLE"

    login_defs="/etc/login.defs"
    if grep -q "^PASS_MAX_DAYS\s\+30" "$login_defs" &&
       grep -q "^PASS_MIN_DAYS\s\+2" "$login_defs" &&
       grep -q "^PASS_WARN_AGE\s\+7" "$login_defs"; then
        print_result "Configuración en /etc/login.defs es correcta." "OK"
    else
        print_result "Advertencia: Configuración en /etc/login.defs no es correcta." "WARN"
    fi
}

# Verificar si está instalado libpam-pwquality y configuración en /etc/pam.d/common-password
check_pam_pwquality() {
    print_result "Verificando libpam-pwquality y configuración de PAM..." "TITLE"

    if dpkg -l | grep -q "libpam-pwquality"; then
        print_result "libpam-pwquality está instalado." "OK"
        pam_config="/etc/pam.d/common-password"
        if grep -q "minlen=10" "$pam_config" &&
           grep -q "ucredit=-1" "$pam_config" &&
           grep -q "dcredit=-1" "$pam_config" &&
           grep -q "lcredit=-1" "$pam_config" &&
           grep -q "maxrepeat=3" "$pam_config" &&
           grep -q "reject_username" "$pam_config" &&
           grep -q "difok=7" "$pam_config" &&
           grep -q "enforce_for_root" "$pam_config"; then
            print_result "Configuración de PAM es correcta." "OK"
        else
            print_result "Advertencia: Configuración de PAM no es correcta." "WARN"
        fi
    else
        print_result "Advertencia: libpam-pwquality no está instalado." "WARN"
    fi
}

# Verificar configuración de chage para root y usuario con ID 1000
check_chage() {
    print_result "Verificando configuración de chage para root y usuario con ID 1000..." "TITLE"

    # Obtener el nombre del usuario con ID 1000
    user_1000=$(getent passwd | awk -F: '$3 == 1000 {print $1}')

    for user in root "$user_1000"; do
        min_days=$(sudo chage -l $user | grep "Minimum number of days between password change" | awk -F: '{print $2}' | xargs)
        max_days=$(sudo chage -l $user | grep "Maximum number of days between password change" | awk -F: '{print $2}' | xargs)
        if [ "$min_days" -eq 2 ] && [ "$max_days" -eq 30 ]; then
            print_result "Configuración de chage para $user es correcta." "OK"
        else
            print_result "Advertencia: Configuración de chage para $user no es correcta." "WARN"
        fi
    done
}

# Ejecutar todas las verificaciones
check_lvm_partitions
check_sudo_user42
check_openssh
check_ufw
check_sudoers_config
check_login_defs
check_pam_pwquality
check_chage

print_result "Verificación completada." "INFO"
