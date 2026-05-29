#!/bin/bash
# ==============================================================================
# Script de Fortificación y Configuración de Firewall iptables para Debian
# Autor: Iván
# ==============================================================================

# IP del servidor de administración (Kali Linux)
KALI_IP="192.168.113.131"

echo "=== Iniciando fortificación de red mediante iptables ==="

# 1. Limpiar todas las reglas y cadenas existentes
echo "[*] Limpiando reglas anteriores..."
sudo iptables -F
sudo iptables -X

# 2. Definir políticas por defecto (DROP en INPUT y FORWARD, ACCEPT en OUTPUT)
echo "[*] Estableciendo políticas DROP por defecto..."
sudo iptables -P INPUT DROP
sudo iptables -P FORWARD DROP
sudo iptables -P OUTPUT ACCEPT

# 3. Permitir tráfico de loopback (local de la máquina)
echo "[*] Permitiendo tráfico de loopback..."
sudo iptables -A INPUT -i lo -j ACCEPT

# 4. Permitir conexiones ya establecidas o relacionadas
echo "[*] Permitiendo tráfico established y related..."
sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# 5. Permitir tráfico Zabbix Agent (puerto 10050) solo desde la IP de Kali
echo "[*] Habilitando puerto Zabbix Agent (10050) para $KALI_IP..."
sudo iptables -A INPUT -p tcp -s $KALI_IP --dport 10050 -j ACCEPT

# 6. Permitir administración remota SSH segura (puerto 2222) solo desde la IP de Kali
echo "[*] Habilitando puerto SSH seguro (2222) para $KALI_IP..."
sudo iptables -A INPUT -p tcp -s $KALI_IP --dport 2222 -j ACCEPT

# 7. Permitir tráfico ICMP (ping) exclusivamente desde la subred interna
echo "[*] Habilitando ping selectivo desde la subred interna..."
sudo iptables -A INPUT -p icmp -s $KALI_IP -j ACCEPT
sudo iptables -A INPUT -p icmp -j DROP

# 8. Guardar reglas de forma persistente
echo "[*] Guardando reglas de forma persistente..."
if [ -d "/etc/iptables" ]; then
    sudo iptables-save | sudo tee /etc/iptables/rules.v4 > /dev/null
    echo "[+] Reglas guardadas con éxito en /etc/iptables/rules.v4"
else
    echo "[!] Advertencia: Directorio /etc/iptables no encontrado."
    echo "[!] Por favor, instala iptables-persistent ejecutando:"
    echo "    sudo apt install iptables-persistent"
fi

echo "=== Configuración de firewall completada con éxito ==="
