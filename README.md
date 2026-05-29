# Laboratorio de Monitorización y Detección de Intrusos (Zabbix + Snort 3 + iptables)

Este repositorio contiene la arquitectura, configuraciones y scripts utilizados para desplegar un laboratorio de seguridad perimetral y monitorización activa en un entorno virtualizado utilizando herramientas de software libre.

## 📋 Arquitectura y Topología de Red

El laboratorio se compone de dos máquinas virtuales configuradas en una **Red Interna** privada aislada (`192.168.113.0/24`) mediante el hipervisor VirtualBox:

```mermaid
graph TD
    subgraph Red Interna (192.168.113.0/24)
        K[Kali Linux - 192.168.113.131] <-->|Monitoriza y Analiza| D[Debian - 192.168.113.128]
    end
    
    K -->|Zabbix Server & Snort 3| K
    D -->|Zabbix Agent & iptables| D
```

* **Servidor Central (Kali Linux - `192.168.113.131`):** Centro defensivo que corre Zabbix Server, la base de datos MariaDB, el servidor web Apache2 + PHP para la interfaz web, y el IDS Snort 3 para analizar el tráfico.
* **Servidor Objetivo (Debian - `192.168.113.128`):** Servidor a proteger que corre Zabbix Agent (puerto `10050`) para reportar métricas de salud e `iptables` como cortafuegos local de fortificación.

---

## 🛠️ Contenido del Repositorio

* `scripts/setup_iptables.sh`: Script automatizado para desplegar las reglas del firewall iptables y asegurar la persistencia tras reinicios en Debian.
* `config/local.rules`: Reglas de detección personalizadas para el IDS Snort 3 (detección de pings ICMP y escaneo SYN de Nmap).
* `config/zabbix_agentd_custom.conf`: Configuración del agente Zabbix para habilitar la monitorización activa del archivo de logs de alertas de Snort.

---

## 🚀 Guía de Despliegue Rápido

### 1. Fortificación de red en Debian
Copia y ejecuta el script `scripts/setup_iptables.sh` en el servidor Debian para aplicar la política DROP por defecto y permitir únicamente puertos de administración específicos desde la IP del servidor de monitorización.

### 2. Configuración de Reglas en Snort 3
Importa el contenido de `config/local.rules` en el archivo de reglas locales de Snort en Kali Linux y ejecuta el motor en modo pasivo/escucha:
```bash
sudo snort -c /etc/snort/snort.lua -i eth0 -A alert_fast
```

### 3. Integración en Zabbix
1. Agrega el parámetro de usuario personalizado en el archivo de configuración del agente Zabbix para que lea el archivo de logs de alertas de Snort `/var/log/snort/alert_fast`.
2. Crea un Trigger en la interfaz web de Zabbix y asócialo a un tipo de medio SMTP para recibir alertas automáticas por correo electrónico ante actividades maliciosas.

---

## 👥 Autor y Créditos
* **Autor:** Iván
* **Centro:** Andel Instituto Tecnológico
* **Tutor:** Pedro Luis
