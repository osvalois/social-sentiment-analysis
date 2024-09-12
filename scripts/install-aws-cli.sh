#!/bin/bash

# Función para instalar AWS CLI en macOS
install_aws_cli_macos() {
    echo "Descargando el instalador de AWS CLI v2 para macOS..."
    curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"

    echo "Verificando la integridad del instalador..."
    shasum -a 256 AWSCLIV2.pkg

    echo "Instalando AWS CLI v2..."
    sudo installer -pkg AWSCLIV2.pkg -target /

    echo "Verificando la instalación de AWS CLI v2..."
    if command -v aws &> /dev/null
    then
        aws --version
        echo "AWS CLI v2 se ha instalado correctamente."
    else
        echo "Hubo un problema durante la instalación."
        exit 1
    fi

    echo "Limpiando archivos de instalación..."
    rm AWSCLIV2.pkg
}

# Función para instalar AWS CLI en Linux (Debian/Ubuntu)
install_aws_cli_linux() {
    echo "Descargando el instalador de AWS CLI v2 para Linux..."
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

    echo "Descomprimiendo el instalador..."
    unzip awscliv2.zip

    echo "Instalando AWS CLI v2..."
    sudo ./aws/install

    echo "Verificando la instalación de AWS CLI v2..."
    if command -v aws &> /dev/null
    then
        aws --version
        echo "AWS CLI v2 se ha instalado correctamente."
    else
        echo "Hubo un problema durante la instalación."
        exit 1
    fi

    echo "Limpiando archivos de instalación..."
    rm awscliv2.zip
    sudo ./aws/install --remove
}

# Detectar el sistema operativo
case "$(uname -s)" in
    Darwin)
        install_aws_cli_macos
        ;;
    Linux)
        if [ -f /etc/debian_version ]; then
            install_aws_cli_linux
        else
            echo "Sistema operativo no soportado. Solo se admite macOS y Debian/Ubuntu."
            exit 1
        fi
        ;;
    *)
        echo "Sistema operativo no soportado. Solo se admite macOS y Linux."
        exit 1
        ;;
esac

# Instrucciones posteriores a la instalación
echo "Recuerda configurar las credenciales de AWS utilizando el comando: aws configure"
