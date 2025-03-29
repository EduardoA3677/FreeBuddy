import argparse
import re

# Configuración del parser para los argumentos de la línea de comandos
p = argparse.ArgumentParser()
p.add_argument('--version', help='Version to get changelog for. You can type with or without "v" prefix', required=True)
args = p.parse_args()

# Eliminar el prefijo 'v' si está presente
version = args.version.strip().replace('v', '')
if not re.match(r'\d+\.\d+\.\d+', version):
    raise ValueError('Invalid version')

# Abrir el archivo CHANGELOG.md
with open("CHANGELOG.md", 'r') as f:
    lines = f.read()

# Buscar la versión correspondiente
start = lines.index(f'## {version}')
start = lines.index('\n', start) + 1
try:
    end = lines.index('\n## ', start)
except ValueError:
    end = -1

# Imprimir el changelog de la versión
print(lines[start:end].strip())
